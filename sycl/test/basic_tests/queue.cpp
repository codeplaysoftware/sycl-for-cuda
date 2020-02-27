// RUN: %clangxx -fsycl -fsycl-targets=%sycl_triple %s -o %t.out
// RUN: env SYCL_DEVICE_TYPE=HOST %t.out
// RUN: %t.out
//==--------------- queue.cpp - SYCL queue test ----------------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "../helpers.hpp"
#include <CL/sycl.hpp>
#include <iostream>

using namespace cl::sycl;

string_class get_type(const device &dev) {
  return ((dev.is_host()) ? "host"
                          : (dev.is_gpu() ? "OpenCL.GPU" : "OpenCL.CPU"));
}

void print_queue_info(const queue &q) {
  std::cout << "ID=" << std::hex
            << ((q.get_device().is_host()) ? nullptr : q.get()) << std::endl;
  std::cout << "queue wraps " << get_type(q.get_device()) << " device"
            << std::endl;
}
int main() {
  try {
    std::cout << "Create default queue." << std::endl;
    queue q;
    print_queue_info(q);

  } catch (device_error e) {
    std::cout << "Failed to create device for context" << std::endl;
    throw;
  }

  auto devices = device::get_devices();
  device &deviceA = devices[0];
  device &deviceB = (devices.size() > 1 ? devices[1] : devices[0]);
  {
    std::cout << "move constructor" << std::endl;
    queue Queue(deviceA);
    size_t hash = hash_class<queue>()(Queue);
    queue MovedQueue(std::move(Queue));
    CHECK(hash == hash_class<queue>()(MovedQueue));
    CHECK(deviceA.is_host() == MovedQueue.is_host());
    if (!deviceA.is_host()) {
      CHECK(MovedQueue.get() != nullptr);
    }
  }
  {
    std::cout << "move assignment operator" << std::endl;
    queue Queue(deviceA);
    size_t hash = hash_class<queue>()(Queue);
    queue WillMovedQueue(deviceB);
    WillMovedQueue = std::move(Queue);
    CHECK(hash == hash_class<queue>()(WillMovedQueue));
    CHECK(deviceA.is_host() == WillMovedQueue.is_host());
    if (!deviceA.is_host()) {
      CHECK(WillMovedQueue.get() != nullptr);
    }
  }
  {
    std::cout << "copy constructor" << std::endl;
    queue Queue(deviceA);
    size_t hash = hash_class<queue>()(Queue);
    queue QueueCopy(Queue);
    CHECK(hash == hash_class<queue>()(Queue));
    CHECK(hash == hash_class<queue>()(QueueCopy));
    CHECK(Queue == QueueCopy);
    CHECK(Queue.is_host() == QueueCopy.is_host());
  }
  {
    std::cout << "copy assignment operator" << std::endl;
    queue Queue(deviceA);
    size_t hash = hash_class<queue>()(Queue);
    queue WillQueueCopy(deviceB);
    WillQueueCopy = Queue;
    CHECK(hash == hash_class<queue>()(Queue));
    CHECK(hash == hash_class<queue>()(WillQueueCopy));
    CHECK(Queue == WillQueueCopy);
    CHECK(Queue.is_host() == WillQueueCopy.is_host());
  }

  {
    property_list pl = {};
    queue Queue(pl);
    try {
      Queue.throw_asynchronous();
    } catch (const std::bad_function_call &e) {
      std::cerr << "Default asynchronous handler call failed: " << e.what()
                << std::endl;
      throw;
    }
  }

  {
    default_selector Selector;
    device Device = Selector.select_device();
    context Context(Device);
    queue Queue(Context, Selector);
    CHECK(Context == Queue.get_context());
  }

  {
    context Context(deviceA);
    queue Queue(Context, deviceA);
    assert(Context == Queue.get_context());
  }

  if (devices.size() > 1) {
    bool GotException = false;
    try {
      context Context(deviceA);
      queue Queue(Context, deviceB);
      assert(Context == Queue.get_context());
    } catch (std::exception &e) {
      std::cout << "Exception check passed: " << e.what() << std::endl;
      GotException = true;
    }
    assert(GotException);
  }
}
