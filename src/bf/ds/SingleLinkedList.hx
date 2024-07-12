package bf.ds;

/**
 * Singly linked list of generic type with memory management features.
 * @template T The type of the data stored in the nodes.
 */
class SingleLinkedList<T> {
    
    /** The data stored in the node. */
    public var data:T;
    
    /** The next node in the list. */
    public var next:SingleLinkedList<T>;
    
    // Free list for recycling nodes
    static private var _freeList:SingleLinkedList<Dynamic> = null;
    
    /**
     * Constructor
     * @param data The initial value for the node (default is null).
     */
    public function new(data:T = null) {
        this.data = data;
    }
    
    /**
     * Allocates a new node, reusing one from the free list if available.
     * @param data The initial value for the node (default is null).
     * @return The allocated node.
     */
    static public function alloc<T>(data:T = null):SingleLinkedList<T> {
        var ret:SingleLinkedList<T>;
        if (_freeList != null) {
            ret = cast _freeList;
            _freeList = _freeList.next;
            ret.data = data;
            ret.next = null;
        } else {
            ret = new SingleLinkedList<T>(data);
        }
        return ret;
    }
    
    /**
     * Allocates a linked list of specified size.
     * @param size The number of nodes in the list.
     * @param defaultData The default value for each node (default is null).
     * @return The head node of the allocated list.
     */
    static public function allocList<T>(size:Int, defaultData:T = null):SingleLinkedList<T> {
        var ret:SingleLinkedList<T> = alloc(defaultData);
        var elem:SingleLinkedList<T> = ret;
        for (i in 1...size) {
            elem.next = alloc(defaultData);
            elem = elem.next;
        }
        return ret;
    }
    
    /**
     * Allocates a ring-linked list of specified size.
     * @param size The number of nodes in the ring.
     * @param defaultData The default value for each node (default is null).
     * @return The head node of the allocated ring.
     */
    static public function allocRing<T>(size:Int, defaultData:T = null):SingleLinkedList<T> {
        var ret:SingleLinkedList<T> = alloc(defaultData);
        var elem:SingleLinkedList<T> = ret;
        for (i in 1...size) {
            elem.next = alloc(defaultData);
            elem = elem.next;
        }
        elem.next = ret;
        return ret;
    }
    
    /**
     * Creates a ring-linked list with initial values.
     * @param args The initial values for each node.
     * @return The head node of the allocated ring.
     */
    static public function newRing<T>(args:Array<T>):SingleLinkedList<T> {
        var size:Int = args.length;
        var ret:SingleLinkedList<T> = alloc(args[0]);
        var elem:SingleLinkedList<T> = ret;
        for (i in 1...size) {
            elem.next = alloc(args[i]);
            elem = elem.next;
        }
        elem.next = ret;
        return ret;
    }
    
    /**
     * Frees a node, adding it to the free list.
     * @param elem The node to be freed.
     */
    static public function free<T>(elem:SingleLinkedList<T>):Void {
        elem.next = cast _freeList;
        _freeList = cast elem;
    }
    
    /**
     * Frees a linked list, adding all nodes to the free list.
     * @param firstElem The head node of the list to be freed.
     */
    static public function freeList<T>(firstElem:SingleLinkedList<T>):Void {
        if (firstElem == null) return;
        var lastElem:SingleLinkedList<T> = firstElem;
        while (lastElem.next != null) {
            lastElem = lastElem.next;
        }
        lastElem.next = cast _freeList;
        _freeList = cast(firstElem, SingleLinkedList<Dynamic>);
    }
    
    /**
     * Frees a ring-linked list, adding all nodes to the free list.
     * @param firstElem The head node of the ring to be freed.
     */
    static public function freeRing<T>(firstElem:SingleLinkedList<T>):Void {
        if (firstElem == null) return;
        var lastElem:SingleLinkedList<T> = firstElem;
        while (lastElem.next != firstElem) {
            lastElem = lastElem.next;
        }
        lastElem.next = cast _freeList;
        _freeList = cast(firstElem, SingleLinkedList<Dynamic>);
    }
    
    /**
     * Creates a pager (array) of nodes from a linked list.
     * @param firstElem The head node of the list.
     * @param fixedSize Whether the array should have a fixed size.
     * @return An array of nodes.
     */
    static public function createListPager<T>(firstElem:SingleLinkedList<T>, fixedSize:Bool):Array<SingleLinkedList<T>> {
        if (firstElem == null) return null;
        var elem:SingleLinkedList<T> = firstElem;
        var size:Int = 1;
        while (elem.next != null) {
            elem = elem.next;
            size++;
        }
        var pager:Array<SingleLinkedList<T>> = new Array<SingleLinkedList<T>>();
       pager.resize(size);
        elem = firstElem;
        for (i in 0...size) {
            pager[i] = elem;
            elem = elem.next;
        }
        return pager;
    }
    
    /**
     * Creates a pager (array) of nodes from a ring-linked list.
     * @param firstElem The head node of the ring.
     * @param fixedSize Whether the array should have a fixed size.
     * @return An array of nodes.
     */
    static public function createRingPager<T>(firstElem:SingleLinkedList<T>, fixedSize:Bool):Array<SingleLinkedList<T>> {
        if (firstElem == null) return null;
        var elem:SingleLinkedList<T> = firstElem;
        var size:Int = 1;
        while (elem.next != firstElem) {
            elem = elem.next;
            size++;
        }
        var pager:Array<SingleLinkedList<T>> = new Array<SingleLinkedList<T>>();
        pager.resize(size);
        elem = firstElem;
        for (i in 0...size) {
            pager[i] = elem;
            elem = elem.next;
        }
        return pager;
    }
}