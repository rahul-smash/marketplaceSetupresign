import 'dart:collection';

class LogicalStack<T> {
  final _stack = Queue<T>();

  get stack => _stack;

  int get length => _stack.length;

  bool canPop() => _stack.isNotEmpty;

  void clearStack() {
    while (_stack.isNotEmpty) {
      _stack.removeLast();
    }
  }

  void push(T element) {
    _stack.addLast(element);
  }

  T pop() {
    T lastElement = _stack.last;
    _stack.removeLast();
    return lastElement;
  }

  T firstPop() {
    T firstElement = _stack.first;
    _stack.removeFirst();
    return firstElement;
  }

  T peak() => _stack.last;

  LogicalStack<T> copy(LogicalStack<T> passedQueue) {
    passedQueue.stack.addAll(_stack);
  }
}
