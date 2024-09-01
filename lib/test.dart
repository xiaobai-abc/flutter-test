void main() {
  var a = Resp(a: "a", b: "b");
  print(a.a);
}

class Resp {
  final String a;
  final String b;
  Resp({required this.a, required this.b});
}
