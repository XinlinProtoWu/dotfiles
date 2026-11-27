#!/usr/bin/env bash
set -u

TESTS="test1 test2 test3 test4 test5"
CPU_PASS=0
GPU_PASS=0
TOTAL=0

# run_test <cpu|gpu> <name>: run one dataset and compare with the expected output.
run_test() {
    local method="$1"
    local name="$2"
    local outfile
    outfile="$(mktemp)"

    if timeout 60 ./matmul "$method" "./dataset/$name.txt" >"$outfile" 2>"${outfile}.err"; then
        if diff -q "./expected/$name.txt" "$outfile" >/dev/null; then
            echo "[PASS] $method $name    $(grep -m 1 '^TIME' "${outfile}.err")"
            if [ "$method" = cpu ]; then
                CPU_PASS=$((CPU_PASS + 1))
            else
                GPU_PASS=$((GPU_PASS + 1))
            fi
        else
            echo "[FAIL] $method $name: output mismatch (first difference below)"
            awk 'NR == FNR { e[FNR] = $0; n = FNR; next }
                 { m = FNR }
                 !d && $0 != e[FNR] { d = FNR; printf "  line %d\n  expected: %.100s\n  got:      %.100s\n", FNR, e[FNR], $0 }
                 END { if (!d) printf "  expected %d lines, got %d\n", n, m }' "./expected/$name.txt" "$outfile"
        fi
    else
        echo "[FAIL] $method $name: command failed or timed out"
        cat "${outfile}.err"
    fi

    rm -f "$outfile" "${outfile}.err"
}

echo "======================================"
echo " Matrix Multiplication Public Test"
echo "======================================"

echo
echo "[1/3] Building..."
if ! (make clean >/dev/null 2>&1 && make all); then
    echo "[FAIL] build"
    echo
    echo "Build failed. Stop testing."
    exit 1
fi
echo "[PASS] build"

echo
echo "[2/3] Running correctness tests..."
for name in $TESTS; do
    echo
    echo "==> $name (M K N = $(head -n 1 "./dataset/$name.txt"))"
    run_test cpu "$name"
    run_test gpu "$name"
    TOTAL=$((TOTAL + 1))
done

echo
echo "[3/3] Timing benchmark (not graded)..."
timeout 120 ./matmul --bench 1024 1024 1024 || echo "Benchmark did not finish (error or 120 s timeout)"

echo
echo "======================================"
echo " Test Summary"
echo "======================================"
echo "CPU: $CPU_PASS/$TOTAL passed"
echo "GPU: $GPU_PASS/$TOTAL passed"

if [ "$CPU_PASS" -eq "$TOTAL" ] && [ "$GPU_PASS" -eq "$TOTAL" ]; then
    echo
    echo "ALL TESTS PASSED"
    exit 0
else
    echo
    echo "SOME TESTS FAILED"
    exit 1
fi
