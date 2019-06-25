# Error and Condition Handling in R

* 2017-01-26
* Speaker: John Peach

## Abstract

Being an interactive language, it is common to not perform a lot of error checking in R. Even popular packages lack often lack the robustness seen in similar tools in other languages. This may be in part due to the background of R developers, the environments where R scripts are used, cultural norms or because the error handling system in R is a little different. Generally, a language handles errors in one of three ways. A function returns a special value on an error (i.e. C, bash) or it throws an exception that unwinds the call stack where the error is dealt with in a different scope (i.e. Java, python). The approach used in R is based on Lisp. In general, errors are handled by a 'condition system' that is powerful and flexible. 

The condition system in R is quite powerful and is designed to deal with sending signals from one part of the call stack to another. These signals can be errors or any other type of message that is desired. It consists of three components, a 'signal' is sent from the executing code, control is transferred to the 'handler' code that handles the signal. Then a 'restart' can be executed. This is in some ways similar to the throw-catch mechanisms in other languages. However, these languages require that the call stack is unwound and the handling of the error is in a different context than where the error occurred. In R, the condition system allows this behavior to be mocked but it also allows the condition to be handled in the context of the code that generated the signal. 

So, what does this mean? It means that we can write code that generates and error at a low level but it is the higher level code that determines how the error is dealt. The system then restarts as if the error did not occur. Put another way, a function can be written such that it abstracts the fixing of errors to higher level code but the fix operates as if it was part of the lower level code. 

I will go over how you can write defensive code using the error handling system in R and will also give examples. The condition system for more than error management. We can see how you can write a general purpose tool that does not know how to fix problems and them wrap that in business logic for a specific application.

