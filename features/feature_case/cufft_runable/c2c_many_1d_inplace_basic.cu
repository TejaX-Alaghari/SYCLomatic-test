// ===--- c2c_many_1d_inplace_basic.cu -----------------------*- CUDA -*---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// ===---------------------------------------------------------------------===//

#include "cufft.h"
#include "cufftXt.h"
#include "common.h"
#include <cstring>
#include <iostream>

bool c2c_many_1d_inplace_basic() {
  cufftHandle plan_fwd;
  cufftCreate(&plan_fwd);
  float2 forward_idata_h[10];
  set_value((float*)forward_idata_h, 10);
  set_value((float*)forward_idata_h + 10, 10);

  float2* data_d;
  cudaMalloc(&data_d, sizeof(float2) * 10);
  cudaMemcpy(data_d, forward_idata_h, sizeof(float2) * 10, cudaMemcpyHostToDevice);

  int n[1] = {5};
  size_t workSize;
  cufftMakePlanMany(plan_fwd, 1, n, nullptr, 0, 0, nullptr, 0, 0, CUFFT_C2C, 2, &workSize);
  cufftExecC2C(plan_fwd, data_d, data_d, CUFFT_FORWARD);
  cudaDeviceSynchronize();
  float2 forward_odata_h[10];
  cudaMemcpy(forward_odata_h, data_d, sizeof(float2) * 10, cudaMemcpyDeviceToHost);

  float2 forward_odata_ref[10];
  forward_odata_ref[0] =  float2{20,25};
  forward_odata_ref[1] =  float2{-11.8819,1.88191};
  forward_odata_ref[2] =  float2{-6.6246,-3.3754};
  forward_odata_ref[3] =  float2{-3.3754,-6.6246};
  forward_odata_ref[4] =  float2{1.88191,-11.8819};
  forward_odata_ref[5] =  float2{20,25};
  forward_odata_ref[6] =  float2{-11.8819,1.88191};
  forward_odata_ref[7] =  float2{-6.6246,-3.3754};
  forward_odata_ref[8] =  float2{-3.3754,-6.6246};
  forward_odata_ref[9] =  float2{1.88191,-11.8819};

  cufftDestroy(plan_fwd);

  if (!compare(forward_odata_ref, forward_odata_h, 10)) {
    std::cout << "forward_odata_h:" << std::endl;
    print_values(forward_odata_h, 10);
    std::cout << "forward_odata_ref:" << std::endl;
    print_values(forward_odata_ref, 10);

    cudaFree(data_d);

    return false;
  }

  cufftHandle plan_bwd;
  cufftCreate(&plan_bwd);
  cufftMakePlanMany(plan_bwd, 1, n, nullptr, 0, 0, nullptr, 0, 0, CUFFT_C2C, 2, &workSize);
  cufftExecC2C(plan_bwd, data_d, data_d, CUFFT_INVERSE);
  cudaDeviceSynchronize();
  float2 backward_odata_h[10];
  cudaMemcpy(backward_odata_h, data_d, sizeof(float2) * 10, cudaMemcpyDeviceToHost);

  float2 backward_odata_ref[10];
  backward_odata_ref[0] =  float2{0,5};
  backward_odata_ref[1] =  float2{10,15};
  backward_odata_ref[2] =  float2{20,25};
  backward_odata_ref[3] =  float2{30,35};
  backward_odata_ref[4] =  float2{40,45};
  backward_odata_ref[5] =  float2{0,5};
  backward_odata_ref[6] =  float2{10,15};
  backward_odata_ref[7] =  float2{20,25};
  backward_odata_ref[8] =  float2{30,35};
  backward_odata_ref[9] =  float2{40,45};

  cudaFree(data_d);
  cufftDestroy(plan_bwd);

  if (!compare(backward_odata_ref, backward_odata_h, 10)) {
    std::cout << "backward_odata_h:" << std::endl;
    print_values(backward_odata_h, 10);
    std::cout << "backward_odata_ref:" << std::endl;
    print_values(backward_odata_ref, 10);
    return false;
  }
  return true;
}


#ifdef DEBUG_FFT
int main() {
#define FUNC c2c_many_1d_inplace_basic
  bool res = FUNC();
  cudaDeviceSynchronize();
  if (!res) {
    std::cout << "Fail" << std::endl;
    return -1;
  }
  std::cout << "Pass" << std::endl;
  return 0;
}
#endif

