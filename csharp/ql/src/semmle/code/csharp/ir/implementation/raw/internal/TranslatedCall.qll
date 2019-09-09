import csharp
private import semmle.code.csharp.ir.implementation.Opcode
private import semmle.code.csharp.ir.implementation.internal.OperandTag
private import InstructionTag
private import TranslatedElement
private import TranslatedExpr
private import semmle.code.csharp.ir.Util
private import semmle.code.csharp.ir.implementation.raw.internal.common.TranslatedCallBase
private import semmle.code.csharp.ir.internal.IRCSharpLanguage as Language

/**
 * The IR translation of a call to a function. The function can be a normal function
 * (ie. `MethodCall`) or a constructor call (ie. `ObjectCreation`). Notice that the
 * AST generated translated calls are tied to an expression (unlike compiler generated ones,
 * which can be attached to either a statement or an expression).
 */
abstract class TranslatedCall extends TranslatedExpr, TranslatedCallBase {
  final override Instruction getResult() { result = TranslatedCallBase.super.getResult() }

  override Instruction getUnmodeledDefinitionInstruction() {
    result = this.getEnclosingFunction().getUnmodeledDefinitionInstruction()
  }
}

/**
 * Represents the IR translation of a direct function call. The call can be one of the following:
 * `MethodCall`, `LocalFunctionCall`, `AccessorCall`, `OperatorCall`.
 * Note that `DelegateCall`s are not treated here since they need to be desugared.
 */
class TranslatedFunctionCall extends TranslatedNonConstantExpr, TranslatedCall {
  override Call expr;

  TranslatedFunctionCall() {
    expr instanceof MethodCall or
    expr instanceof LocalFunctionCall or
    expr instanceof AccessorCall or
    expr instanceof OperatorCall
  }

  override Callable getInstructionFunction(InstructionTag tag) {
    tag = CallTargetTag() and result = expr.getTarget()
  }

  override TranslatedExpr getArgument(int index) {
    result = getTranslatedExpr(expr.getArgument(index))
  }

  override TranslatedExpr getQualifier() {
    expr instanceof QualifiableExpr and
    result = getTranslatedExpr(expr.(QualifiableExpr).getQualifier())
  }

  override Instruction getQualifierResult() { result = this.getQualifier().getResult() }

  override Type getCallResultType() { result = expr.getTarget().getReturnType() }

  override predicate hasReadSideEffect() {
    not expr.getTarget().(SideEffectFunction).neverReadsMemory()
  }

  override predicate hasWriteSideEffect() {
    not expr.getTarget().(SideEffectFunction).neverWritesMemory()
  }
}

/**
 * Represents the IR translation of a call to a constructor or to a constructor initializer.
 * The qualifier of the call is obtained from the constructor call context.
 * Note that `DelegateCreation` is not present here, since the call to a delegate constructor is
 * compiler generated.
 */
class TranslatedConstructorCall extends TranslatedNonConstantExpr, TranslatedCall {
  override Call expr;

  TranslatedConstructorCall() {
    expr instanceof ObjectCreation or
    expr instanceof ConstructorInitializer
  }

  override Callable getInstructionFunction(InstructionTag tag) {
    tag = CallTargetTag() and result = expr.getTarget()
  }

  override TranslatedExpr getArgument(int index) {
    result = getTranslatedExpr(expr.getArgument(index))
  }

  // The qualifier for a constructor call has already been generated
  // (the `NewObj` instruction)
  override TranslatedExpr getQualifier() { none() }

  override Type getCallResultType() { result instanceof VoidType }

  override Instruction getQualifierResult() {
    exists(ConstructorCallContext context |
      context = this.getParent() and
      result = context.getReceiver()
    )
  }
}
