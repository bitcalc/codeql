import python


private import semmle.python.objects.TObject
private import semmle.python.objects.ObjectInternal
private import semmle.python.pointsto.PointsTo2
private import semmle.python.pointsto.PointsToContext2
private import semmle.python.types.Builtins

class SpecificInstanceInternal extends TSpecificInstance, ObjectInternal {

    override string toString() {
        result = "instance of " + this.getClass().(ClassObjectInternal).getName()
    }

    /** The boolean value of this object, if it has one */
    override boolean booleanValue() {
        //this.getClass().instancesAlways(result)
        none()
    }

    /** Holds if this object may be true or false when evaluated as a bool */
    override predicate maybe() {
        // this.getClass().instancesMaybe()
        any()
    }

    override predicate introduced(ControlFlowNode node, PointsToContext2 context) {
        this = TSpecificInstance(node, _, context)
    }

    /** Gets the class declaration for this object, if it is a declared class. */
    override ClassDecl getClassDeclaration() {
        none()
    }

    override boolean isClass() { result = false }

    override boolean isComparable() { result = false }

    override ObjectInternal getClass() {
        this = TSpecificInstance(_, result, _)
    }

    /** Gets the `Builtin` for this object, if any.
     * All objects (except unknown and undefined values) should return 
     * exactly one result for either this method or `getOrigin()`.
     */
    override Builtin getBuiltin() {
        none()
    }

    /** Gets a control flow node that represents the source origin of this 
     * objects.
     * All objects (except unknown and undefined values) should return 
     * exactly one result for either this method or `getBuiltin()`.
     */
    override ControlFlowNode getOrigin() {
        this = TSpecificInstance(result, _, _)
    }

    /** Holds if `obj` is the result of calling `this` and `origin` is
     * the origin of `obj`.
     */
    override predicate callResult(PointsToContext2 callee, ObjectInternal obj, CfgOrigin origin) {
        // In general instances aren't callable, but some are...
        // TO DO -- Handle cases where class overrides __call__
        none()
    }

    override int intValue() {
        none()
    }

    override string strValue() {
        none()
    }

    override predicate calleeAndOffset(Function scope, int paramOffset) {
        none()
    }

    override predicate attribute(string name, ObjectInternal value, CfgOrigin origin) {
        none()
    }

    override predicate attributesUnknown() { any() }

}

/** Represents a value that has a known class, but no other information */
class UnknownInstanceInternal extends TUnknownInstance, ObjectInternal {

    override string toString() {
        result = "instance of " + this.getClass().(ClassObjectInternal).getName()
    }

    /** The boolean value of this object, if it has one */
    override boolean booleanValue() {
        //this.getClass().instancesAlways(result)
        none()
    }

    /** Holds if this object may be true or false when evaluated as a bool */
    override predicate maybe() {
        // this.getClass().instancesMaybe()
        any()
    }

    override predicate introduced(ControlFlowNode node, PointsToContext2 context) {
        none()
    }

    /** Gets the class declaration for this object, if it is a declared class. */
    override ClassDecl getClassDeclaration() {
        none()
    }

    override boolean isClass() { result = false }

    override boolean isComparable() { result = false }

    override ObjectInternal getClass() {
        this = TUnknownInstance(result)
    }

    /** Gets the `Builtin` for this object, if any.
     * All objects (except unknown and undefined values) should return 
     * exactly one result for either this method or `getOrigin()`.
     */
    override Builtin getBuiltin() {
        none()
    }

    /** Gets a control flow node that represents the source origin of this 
     * objects.
     * All objects (except unknown and undefined values) should return 
     * exactly one result for either this method or `getBuiltin()`.
     */
    override ControlFlowNode getOrigin() {
        none()
    }

    /** Holds if `obj` is the result of calling `this` and `origin` is
     * the origin of `obj`.
     */
    override predicate callResult(PointsToContext2 callee, ObjectInternal obj, CfgOrigin origin) {
        // In general instances aren't callable, but some are...
        // TO DO -- Handle cases where class overrides __call__
        none()
    }

    override int intValue() {
        none()
    }

    override string strValue() {
        none()
    }

    override predicate calleeAndOffset(Function scope, int paramOffset) {
        none()
    }

    override predicate attribute(string name, ObjectInternal value, CfgOrigin origin) {
        none()
    }

    override predicate attributesUnknown() { any() }

}
