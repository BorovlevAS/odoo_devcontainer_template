#!/bin/bash
#
# Quick test runner — no DB drop/recreate, uses --update instead of --init.
# DB is created automatically if it does not exist.
#
# Usage:
#   ./run_quick_test.sh --db <db_name> --modules <mod1,mod2> [--py <tags>] [--js <tags>] [--mode py|js|all]
#
# Required:
#   --db      <name>         Database name
#   --modules <mod1,mod2>    Comma-separated Odoo modules to load
#
# Optional:
#   --py  <tags>   --test-tags value for Python tests, e.g. "/module:Class.method"
#                  Omit to run ALL pure Python tests (JS suites auto-excluded via -js_suite tag)
#                  Pass "-" to skip Python tests entirely
#   --js  <tags>   --test-tags value for JS tests (HttpCase method).
#                  Format: /module_name:ClassName.method_name  (note the leading /)
#                  e.g.: "/simbioz_budget:BudgetJSSuite.test_js_lines_matrix"
#                  Omit to run ALL JS suites (auto-selected via js_suite tag)
#                  Pass "-" to skip JS tests entirely
#
# How py/js separation works:
#   JS HttpCase classes carry @tagged("js_suite") in their test_js.py.
#   --mode py  → --test-tags=-js_suite  (excludes js_suite tagged classes)
#   --mode js  → --test-tags=js_suite   (runs only js_suite tagged classes)
#   --mode py|js|all  What to run (default: all)
#
# JS test-tags reference (per test_js.py methods):
#   /simbioz_budget:BudgetJSSuite.test_js_date_range_field       → BudgetDateRangeField QUnit group
#   /simbioz_budget:BudgetJSSuite.test_js_lines_matrix           → BudgetLinesMatrix QUnit group
#   /simbioz_budget:BudgetJSSuite.test_js_utils                  → budget_lines_matrix utils QUnit group
#   /simbioz_budget_cashflow_connector:BudgetCashflowConnectorJSSuite.test_js_cashflow_lines_matrix  → CashFlowLinesMatrix
#   /simbioz_budget_cashflow_connector:BudgetCashflowConnectorJSSuite.test_js_compute_balance_rows   → computeBalanceRows
#
# Examples:
#   # All tests (Python + JS)
#   ./run_quick_test.sh --db tests --modules simbioz_budget,simbioz_budget_cashflow_connector
#
#   # Only JS, all groups
#   ./run_quick_test.sh --db tests --modules simbioz_budget,simbioz_budget_cashflow_connector --mode js
#
#   # Only JS, one specific QUnit group
#   ./run_quick_test.sh --db tests --modules simbioz_budget \
#       --js "/simbioz_budget:BudgetJSSuite.test_js_lines_matrix" --mode js
#
#   # Only Python, specific method
#   ./run_quick_test.sh --db tests --modules simbioz_budget \
#       --py "/simbioz_budget:TestSimbiozBudgetExemplar.test_cascade_delete" --mode py
#
#   # Python + one JS group
#   ./run_quick_test.sh --db tests --modules simbioz_budget \
#       --js "/simbioz_budget:BudgetJSSuite.test_js_date_range_field"

DBNAME=""
MODULES=""
PY_TAGS=""
JS_FILTER=""
MODE="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --db)      DBNAME="$2";    shift 2 ;;
    --modules) MODULES="$2";   shift 2 ;;
    --py)      PY_TAGS="$2";   shift 2 ;;
    --js)      JS_FILTER="$2"; shift 2 ;;
    --mode)    MODE="$2";      shift 2 ;;
    *) echo -e "\033[0;31mUnknown option: $1\033[0m"; exit 1 ;;
  esac
done

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [[ -z "${DBNAME}" || -z "${MODULES}" ]]; then
  echo -e "${RED}Required: --db <name> --modules <mod1,mod2>${NC}"
  echo -e "${RED}Run with no args to see full usage.${NC}"
  exit 1
fi

# Initialize DB (create if not exists, update modules if already exists)
echo -e "${GREEN}=== INITIALIZING DATABASE ===${NC}"

unbuffer python3 odoo-bin --config=/workspace/conf/odoo-server.conf \
  --database=${DBNAME} --init=${MODULES} \
  --stop-after-init --log-level=error

init_result=$?
if [ $init_result -ne 0 ]; then
  echo -e "${RED}=== INITIALIZATION FAILED ===${NC}"
  exit $init_result
fi

echo -e "${BLUE}=== QUICK TEST RUN ===${NC}"
echo -e "${BLUE}Database : ${DBNAME}${NC}"
echo -e "${BLUE}Modules  : ${MODULES}${NC}"
echo -e "${BLUE}Mode     : ${MODE}${NC}"
[[ -n "${PY_TAGS}" && "${PY_TAGS}" != "-" ]] && echo -e "${BLUE}Py tags  : ${PY_TAGS}${NC}"
[[ -n "${JS_FILTER}" && "${JS_FILTER}" != "-" ]] && echo -e "${BLUE}JS filter: ${JS_FILTER}${NC}"
echo ""

overall_result=0

run_python_tests() {
  local tags_arg=""
  if [[ -n "${PY_TAGS}" && "${PY_TAGS}" != "-" ]]; then
    # Explicit tags override — user targets a specific test
    tags_arg="--test-tags=${PY_TAGS}"
  else
    # Exclude JS suites (tagged "js_suite") so only pure Python tests run
    tags_arg="--test-tags=-js_suite"
  fi

  echo -e "${GREEN}=== PYTHON TESTS ===${NC}"

  unbuffer python3 odoo-bin --config=/workspace/conf/odoo-server.conf \
    --database=${DBNAME} --update=${MODULES} \
    --test-enable \
    --stop-after-init --log-level=info \
    ${tags_arg} 2>&1 | tee /tmp/odoo_quick_test_py.log | \
    grep -Ei "(Starting [A-Za-z]|FAIL:|ERROR.*test|failed.*error|0 failed|tests\.$)"

  py_result=${PIPESTATUS[0]}

  echo ""
  # Extract summary line
  summary=$(grep -E "[0-9]+ failed.*[0-9]+ error" /tmp/odoo_quick_test_py.log | tail -1)
  [[ -n "$summary" ]] && echo -e "${BLUE}Summary: ${summary}${NC}"

  if [ $py_result -eq 0 ]; then
    echo -e "${GREEN}  Python tests PASSED${NC}"
  else
    echo -e "${RED}  Python tests FAILED (exit: $py_result) — see /tmp/odoo_quick_test_py.log${NC}"
    overall_result=$py_result
  fi
}

run_js_tests() {
  local tags_arg=""
  if [[ -n "${JS_FILTER}" && "${JS_FILTER}" != "-" ]]; then
    # Explicit tags override — user targets a specific JS suite/method
    tags_arg="--test-tags=${JS_FILTER}"
  else
    # Run only classes tagged "js_suite" (all HttpCase QUnit suites)
    tags_arg="--test-tags=js_suite"
  fi

  echo -e "${GREEN}=== JS TESTS ===${NC}"
  [[ -n "${tags_arg}" ]] && echo -e "${YELLOW}  tags: ${JS_FILTER}${NC}"

  unbuffer python3 odoo-bin --config=/workspace/conf/odoo-server.conf \
    --database=${DBNAME} --update=${MODULES} \
    --test-enable \
    --http-interface=localhost \
    --stop-after-init --log-level=info \
    ${tags_arg} 2>&1 | tee /tmp/odoo_quick_test_js.log | \
    grep -Ei "(passed [0-9]+|QUnit test failed|test successful|test failed|ERROR)"

  js_result=${PIPESTATUS[0]}

  echo ""
  if [ $js_result -eq 0 ]; then
    echo -e "${GREEN}  JS tests PASSED${NC}"
  else
    echo -e "${RED}  JS tests FAILED (exit: $js_result) — see /tmp/odoo_quick_test_js.log${NC}"
    overall_result=$js_result
  fi
}

case "${MODE}" in
  py)
    run_python_tests
    ;;
  js)
    [[ "${PY_TAGS}" == "-" || -z "${PY_TAGS}" ]] && true  # skip py
    run_js_tests
    ;;
  all)
    if [[ "${PY_TAGS}" != "-" ]]; then
      run_python_tests
    fi
    if [[ "${JS_FILTER}" != "-" ]]; then
      run_js_tests
    fi
    ;;
  *)
    echo -e "${RED}Unknown mode '${MODE}'. Use: py | js | all${NC}"
    exit 1
    ;;
esac

echo ""
if [ $overall_result -eq 0 ]; then
  echo -e "${GREEN}=== ALL DONE — PASSED ===${NC}"
else
  echo -e "${RED}=== ALL DONE — FAILED ===${NC}"
fi
