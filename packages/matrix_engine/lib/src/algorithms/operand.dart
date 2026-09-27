import '../rational/rational.dart';

/// [value] as a term or factor inside a written calculation. A negative value
/// is bracketed, so a reader never meets "3 + -15" or "2 \cdot -4".
String operandLatex(Rational value) =>
    value.isNegative ? '(${value.toLatex()})' : value.toLatex();
