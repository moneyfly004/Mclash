
class ReturnResultError {
  ReturnResultError(this.message, {this.report = true, this.stacktrace});

  String message;
  bool report;
  StackTrace? stacktrace;
}

class ReturnResult<T> {
  ReturnResult({this.handled, this.error, this.data});
  bool? handled;
  ReturnResultError? error;
  T? data;
}
