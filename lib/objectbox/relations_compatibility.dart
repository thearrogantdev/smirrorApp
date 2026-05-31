import 'dart:collection';

class ToOne<T> {
  T? target;
  int targetId = 0;

  ToOne({this.target, this.targetId = 0});
}

class ToMany<T> extends ListBase<T> {
  final List<T> _innerList = [];

  ToMany([Iterable<T>? initial]) {
    if (initial != null) {
      _innerList.addAll(initial);
    }
  }

  @override
  int get length => _innerList.length;

  @override
  set length(int newLength) {
    _innerList.length = newLength;
  }

  @override
  T operator [](int index) => _innerList[index];

  @override
  void operator []=(int index, T value) {
    _innerList[index] = value;
  }

  @override
  void add(T element) {
    _innerList.add(element);
  }

  @override
  void addAll(Iterable<T> iterable) {
    _innerList.addAll(iterable);
  }

  @override
  void clear() {
    _innerList.clear();
  }

  @override
  bool remove(Object? element) {
    return _innerList.remove(element);
  }

  @override
  T removeAt(int index) {
    return _innerList.removeAt(index);
  }

  @override
  void insert(int index, T element) {
    _innerList.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _innerList.insertAll(index, iterable);
  }

  @override
  T removeLast() {
    return _innerList.removeLast();
  }

  @override
  void removeWhere(bool Function(T element) test) {
    _innerList.removeWhere(test);
  }

  @override
  void retainWhere(bool Function(T element) test) {
    _innerList.retainWhere(test);
  }

  @override
  List<T> toList({bool growable = true}) => List<T>.from(_innerList, growable: growable);
}
