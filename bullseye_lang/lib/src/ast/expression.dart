import 'package:bullseye_lang/bullseye_lang.dart';
import 'package:kernel/ast.dart' as k;
import 'package:source_span/source_span.dart';
import 'node.dart';

abstract class Expression extends Node {
  Expression(List<Token> comments, FileSpan span) : super(comments, span);

  Expression get innermost => this;
}

class Annotation extends Node {
  final Expression value;

  Annotation(List<Token> comments, FileSpan span, this.value)
      : super(comments, span);
}

class Identifier extends Expression {
  final Token token;
  String _name;

  Identifier(List<Token> comments, this.token, [this._name])
      : super(comments, token.span);

  Identifier.synthetic(List<Token> comments, FileSpan span, String name)
      : token = null,
        super(comments, span) {
    _name = name;
  }

  String get name => _name ?? token.span.text;
}

class ParenthesizedExpression extends Expression {
  final Expression innermost;

  ParenthesizedExpression(List<Token> comments, FileSpan span, this.innermost)
      : super(comments, span);
}

class AwaitedExpression extends Expression {
  final Expression target;

  AwaitedExpression(List<Token> comments, FileSpan span, this.target)
      : super(comments, span);
}

class NonNullCoercedExpression extends Expression {
  final Expression target;

  NonNullCoercedExpression(List<Token> comments, FileSpan span, this.target)
      : super(comments, span);
}

class FunctionExpression extends Expression {
  final List<FunctionExpressionParameter> parameters;
  final k.AsyncMarker asyncMarker;
  final Expression returnValue;

  FunctionExpression(List<Token> comments, FileSpan span, this.parameters,
      this.asyncMarker, this.returnValue)
      : super(comments, span);
}

class FunctionExpressionParameter extends Parameter {
  @override
  final TypeNode type;

  FunctionExpressionParameter(List<Annotation> annotations,
      List<Token> comments, FileSpan span, Identifier name, this.type)
      : super(annotations, comments, span, name);
}

/// `let identifier = value in body`
/// `let [functionDeclaration] in body`
class LetInExpression extends Expression {
  final Identifier identifier;
  final Expression value, body;
  final FunctionDeclaration functionDeclaration;

  LetInExpression(List<Token> comments, FileSpan span, this.identifier,
      this.value, this.body)
      : functionDeclaration = null,
        super(comments, span);

  LetInExpression.forFunction(this.functionDeclaration, this.body)
      : identifier = null,
        value = null,
        super(functionDeclaration.comments, functionDeclaration.span);
}

/// `left; right`
class SequenceExpression extends Expression {
  final Expression left, right;

  SequenceExpression(List<Token> comments, FileSpan span, this.left, this.right)
      : super(comments, span);
}

/// `begin returnValue end`
class BeginEndExpression extends Expression {
  // final List<LetBinding> letBindings;
  // final List<Expression> ignoredExpressions;
  final Expression returnValue;

  BeginEndExpression(List<Token> comments, FileSpan span, this.returnValue)
      : super(comments, span);
}


class RecordExpression extends Expression {
  final Expression withBinding;
  final List<RecordKVPair> pairs;

  RecordExpression(
      List<Token> comments, FileSpan span, this.withBinding, this.pairs)
      : super(comments, span);
}

class RecordKVPair extends Expression {
  final Identifier identifier;
  final Expression expression;

  RecordKVPair(
      List<Token> comments, FileSpan span, this.identifier, this.expression)
      : super(comments, span);

  String get name => identifier.name;
}
