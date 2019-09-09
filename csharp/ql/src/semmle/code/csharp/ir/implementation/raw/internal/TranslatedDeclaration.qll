import csharp
private import semmle.code.csharp.ir.implementation.Opcode
private import semmle.code.csharp.ir.internal.IRUtilities
private import semmle.code.csharp.ir.implementation.internal.OperandTag
private import InstructionTag
private import TranslatedElement
private import TranslatedExpr
private import TranslatedInitialization
private import semmle.code.csharp.ir.internal.IRCSharpLanguage as Language
private import common.TranslatedDeclarationBase

/**
 * Gets the `TranslatedDeclaration` that represents the declaration
 * `entry`.
 */
TranslatedLocalDeclaration getTranslatedLocalDeclaration(LocalVariableDeclExpr declExpr) {
  result.getAST() = declExpr
}

/**
 * Represents the IR translation of a declaration within the body of a function.
 */
abstract class TranslatedLocalDeclaration extends TranslatedElement, TTranslatedDeclaration {
  LocalVariableDeclExpr expr;

  TranslatedLocalDeclaration() { this = TTranslatedDeclaration(expr) }

  final override Callable getFunction() { result = expr.getEnclosingCallable() }

  final override string toString() { result = expr.toString() }

  final override Language::AST getAST() { result = expr }
}

/**
 * Represents the IR translation of the declaration of a local variable,
 * including its initialization, if any.
 */
class TranslatedLocalVariableDeclaration extends TranslatedLocalDeclaration,
  LocalVariableDeclarationBase, InitializationContext {
  LocalVariable var;

  TranslatedLocalVariableDeclaration() { var = expr.getVariable() }

  override Instruction getTargetAddress() {
    result = this.getInstruction(InitializerVariableAddressTag())
  }

  override LocalVariable getDeclVar() { result = var }

  override Type getVarType() { result = getVariableType(getDeclVar()) }

  override Type getTargetType() { result = getVariableType(var) }

  override IRVariable getInstructionVariable(InstructionTag tag) {
    (
      tag = InitializerVariableAddressTag()
      or
      this.hasUninitializedInstruction() and tag = InitializerStoreTag()
    ) and
    result = getIRUserVariable(getFunction(), getDeclVar())
  }

  override TranslatedInitialization getInitialization() {
    // First complex initializations
    if var.getInitializer() instanceof ArrayCreation
    then result = getTranslatedInitialization(var.getInitializer().(ArrayCreation).getInitializer())
    else
      if var.getInitializer() instanceof ObjectCreation
      then result = getTranslatedInitialization(var.getInitializer())
      else
        // then the simple variable initialization
        result = getTranslatedInitialization(var.getInitializer())
  }

  override predicate isInitializedByElement() { expr.getParent() instanceof IsExpr }
}
