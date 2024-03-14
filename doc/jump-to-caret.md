# JumpToCaret command

This PR introduces a new JumpToCaret command that allows to move the program execution to the first PC associated to the specific AST node associated to where the caret has been placed.

The command itself can be accessed via the advanced steps menu in the debugger toolbar:

![image](https://user-images.githubusercontent.com/97704417/199499862-1f6286e9-1641-4673-89ec-0eb710bfea99.png)

You should put your caret somewhere in the code before using this command, otherwise it will go back to the beginning of the method (even before the creation of temporaries).

## Tutorial: What you can do with JumpToCaret

### Everything that you can do with `SkipUpTo`:
  
* Jump to caret forward to skip instructions to caret:

In the screnshot below, `a`  is equal to 1 and we jump to caret that is on the `a * 42` message node:

![image](https://user-images.githubusercontent.com/97704417/199500697-33ec53cd-82e4-4fd3-aba0-2bc4698dc2e2.png)

After jumping to caret, the next instruction that will be executed is the `a * 42` message node. You can also see that `a` is still equal to 1 as the assignment `a := a +2` has been skipped:

![image](https://user-images.githubusercontent.com/97704417/199501275-aa064c79-25e4-43cf-a711-e3587beb0bad.png)

* Jump to caret inside an inlined block (such as an ifTrue: or ifFalse: block)

In the screenshot below, we put our caret inside the ifFalse: block:

![image](https://user-images.githubusercontent.com/97704417/199502028-cb430763-59ed-4a17-a0bf-5a0c81569a62.png)

After jumping to caret, we have entered the ifFalse: block and `a` is still nil, as the assignment `a := true` has been skipped.

![image](https://user-images.githubusercontent.com/97704417/199502784-3acfaea0-95d2-46cd-b9aa-3ff70b1a9795.png)

Then, you can enter the ifTrue: block if you want too: 

![image](https://user-images.githubusercontent.com/97704417/199502718-ad73304a-0115-49cc-9fb7-f1c159401c3b.png)

![image](https://user-images.githubusercontent.com/97704417/199502875-7a47809f-92a5-43e9-9619-532bb6fff8b6.png)

### You can also do other things that you cannot do with the SkipUpTo command:

* JumpToCaret allows to go backward in the execution, while keeping the state of the program before jumping to caret.

In this screenshot below, `a` is equal to 1, and we want to jump to caret on the message node `a + 2`:

![image](https://user-images.githubusercontent.com/97704417/199504092-b114a516-e84f-42ea-b484-523f15475353.png)

After jumping to caret, as you'd expect, the next instruction that will be executed is the message node: 

![image](https://user-images.githubusercontent.com/97704417/199504431-8ac8c26d-3520-4bb8-8343-c3024d6e832e.png)

If you step twice, the message node `a + 2` and the assignment node `a := a +2` will be executed and `a` will be equal to 3:

![image](https://user-images.githubusercontent.com/97704417/199505116-2deb0072-bd31-48d4-b7c5-e48fa3aa05f5.png)

Now, what you can do with jumpToCaret and that you can't do with skipUpTo is jumping back to caret on the `a + 2` message node:

![image](https://user-images.githubusercontent.com/97704417/199505241-d2cdc77d-13c9-4cb7-a8b1-aa3f7d5c7ab2.png)

Then you can step twice again to execute the message node and the assignment node and `a` will be equal to 5:

![image](https://user-images.githubusercontent.com/97704417/199505392-c87caaee-961c-40a5-ad1e-761cd9abb691.png)

So, jumpToCaret is very useful if you want to see and debug what happens when a piece of code is executed several times.

* JumpToCaret allows to jump inside a non-inlined (embedded or not) block (= that needs to be evalued and that creates their own context)

In the screenshot below, `a` is equal to 1 and the next instruction that will be executed is the message node `a + 2`, whose receiver value 1 has already been pushed on the stack:

![image](https://user-images.githubusercontent.com/97704417/199506520-7d69c628-2978-4f1c-bf97-7dac8dacc1c8.png)

If we move to caret, inside the block, on the `a + 1` message node, then, as you'd expect, the next instruction that will be executed is the `a + 1` message node inside the block. However, as the block is not inlined, a context has been created for it and it has become the suspended context:

![image](https://user-images.githubusercontent.com/97704417/199507339-ca9dc453-3cd5-45c0-beea-528cf0f896b3.png)

Now, stepping twice will execute the `a + 1` message node and the ` a := a + 1` assignment node AND the block return. So the result of the block is put on the stack. After exiting the block context via these steps,  you go back in the parent context right after the block creation:

![image](https://user-images.githubusercontent.com/97704417/199509395-288f55fb-6055-4825-9269-6f10760f300b.png)

You should be really careful when exiting a block via steps if you have entered this block via the jumpToCaret command, as the result of the block is pushed on the stack and becomes the argument of the next bytecode that should be executed (as its real argument had already been pushed on the stack before jumping to caret). If this is not intended, you should reexecute the jumpToCaret command to jump to where you are in order to clean the stack: 

![image](https://user-images.githubusercontent.com/97704417/199509590-0998176f-997e-4453-bc84-014837dee0fb.png)

After jumping to caret, the stack has been cleaned (stackTop is not 2 that was the result of the block anymore).

Note that you can enter embedded blocks. In this case, as many contexts as there are embedding levels are created:

![image](https://user-images.githubusercontent.com/97704417/199510368-c246ef15-36dc-46c4-8e14-6a837861d81e.png)

![image](https://user-images.githubusercontent.com/97704417/199510514-9e4971b8-4448-4af8-a68a-962a7b560d55.png)

So, jumpToCaret is useful to see and debug what happens when a block that is never evaluated is actually evaluated.

* jumpToCaret allows to jump outside a block (whether it's embedded or not)

In the screenshot below, we have entered an embedded block thanks to the `jumpToCaret` command and the next instruction that is going to be executed is the `a + 1` message node:

![image](https://user-images.githubusercontent.com/97704417/199511658-c69d2961-9175-4f7f-b216-7e8b244e6019.png)

After jumping to caret outside the block, on the `a + 2` message node, then as this message node is in the home context method node, all contexts above the suspended context are discarded and, as you'd expect, the next instruction that is going to be executed is the `a + 2` message node:

![image](https://user-images.githubusercontent.com/97704417/199512309-00714bb2-a7be-4ff9-b623-d5463c1e9cc1.png)

Note that if the aimed node was outside the suspended context block node, but inside another context (let's call it C) block node whose context is between the suspended context and its home context, then only the contexts above the context C are discarded:

![image](https://user-images.githubusercontent.com/97704417/199513271-05f6efd4-2459-4e96-80a7-7502e6a4c32c.png)

![image](https://user-images.githubusercontent.com/97704417/199513315-c39578e9-157f-4a71-b43c-13d4cd1ebec4.png)

So, jumpToCaret is useful to exit non-inlined blocks, in order to go back to a context between its sender context and its home context, without executing the rest of the block closure.

### What you cannot do with jumpToCaret:

* As skipUpTo, jumpToCaret does not allow to skip return nodes **yet**.

Except when the return node is in a non-inlined block (non-local return) as jumping outside non-inlined block discards the entire context, it is not possible to jump over a return bytecode.

This is a problem inherited from skipUpTo, as we didn't allow skipUpTo to skip return bytecodes because a context needs to return something.

Of course, you will never see any code after a return node that is not in a block because Pharo does not allow to write unreachable code (except in DoIts and unreachable code after ifTrue: ifFalse: blocks that contain returns , but we don't take these cases into account, as anyway this code is never executed normally).

However, this can become a problem in the case below:

![image](https://user-images.githubusercontent.com/97704417/199517675-f0bcab0b-bae3-4c4e-b52b-e5c7e468d2ae.png)

Here, we want to jump to caret on the `a := 3` assignment node, after an ifFalse: ifTrue: message. However, jumping to caret does not stop on the assignment but it stops on the return node in  the `ifTrue:` block because it has a return node and this block is inlined in the method bytecode, before the aimed node:

![image](https://user-images.githubusercontent.com/97704417/199518649-00390554-e134-407a-8080-33a989c355d3.png)

The bug also appears with skipUpTo and this is a problem as the assignment `a := 3` is reachable so this should be possible to jump to it.

Here, it is possible to go there without executing anything by:
° jump to caret at the end of the ifFalse: block : 

![image](https://user-images.githubusercontent.com/97704417/199519522-642f3987-3ff1-4818-94af-72147d433fc4.png)

° skipping the last instruction of the ifFalse: block that doesn't return: 

![image](https://user-images.githubusercontent.com/97704417/199519947-a93d1a15-f92f-4164-83c4-d99295749406.png)

![image](https://user-images.githubusercontent.com/97704417/199520501-2f753095-f580-488b-aa4c-15309b5e39a9.png)

° stepping over (that keeps the program state as it is. Here, it just jumps after the ifTrue: block as it considers that the ifFalse: block has been executed):

![image](https://user-images.githubusercontent.com/97704417/199520790-cbe41b96-7fc9-4f23-95d5-97471806f269.png)

However this is really tedious and we have to think about a way to make it work. Furthermore, there are some cases for which no easy workaround exists. In the screenshot below, we want to enter the inlined ifTrue: block in the ifTrue:ifFalse: message:

![image](https://user-images.githubusercontent.com/97704417/199521325-3ed96839-e11b-4765-aed6-402aa6d24cf5.png)

After jumping to caret, we stop on the return node in the inlined ifFalse: block because it is before the inlined ifTrue: block:

![image](https://user-images.githubusercontent.com/97704417/199521790-7b5d72d0-0778-4035-ae07-5bf064efa970.png)

* It is not possible to jump to caret within a context that is not the top context yet

## Implementation notes:
- 
  * We get the AST node associated to the caret and get the first PC in the method associated to the AST node. If it is nil, then we check if the node is actually in the method (or block) node. If it is not in the method node and if it is not in the home context method node, we signal an error.  If it is not in the method node but if it is in the home context method node, that means we want to exit a block and we discard the contexts above to exit the block and jump to the aimed node in this context.
  * If the aimedPC for the aimed node is nil and if the aimed node is a recursive child of the method node (this is the case for variable nodes in assignments for example), then we get the first node that is executed after the aimed node and that has a PC associated to it and then we move to the first PC associated to this node instead. If this node is a block node, then this means that we want to enter a block. Then after having jumped to the block creation, we step the block creation bytecode to get the block closure and create a new context for it. We set this new block context as the suspended context in the process and the debug session and we recursively `moveToNode:` to jump to the aimed node in the new context.
- In the implementation, I work with AST node identity, because, for instance if we want to jump to an RBLiteralValueNode 1, we want to jump to this specific node and not any other RBLiteralValueNode 1 that could be anywhere else in the method node.

## Known related issues:
- #55 (minor issue, will be fixed shortly)
- return node in inlined block issue (annoying issue that prevents to use this command at full power but does not induce any crash), will be fixed shortly
- It is not possible to jump to caret within a context that is not the top context