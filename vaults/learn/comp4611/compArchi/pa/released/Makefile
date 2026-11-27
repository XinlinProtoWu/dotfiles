NVCC      := nvcc
NVCCFLAGS := -O2 -std=c++17 -arch=sm_86 -Xcompiler -Wall,-Wextra

BIN := matmul

.PHONY: all clean test

all: $(BIN)

$(BIN): matmul.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@

test: all
	bash ./test.sh

clean:
	rm -f $(BIN)
