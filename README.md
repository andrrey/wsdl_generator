wsdl_generator
==============

This script will generate WSDL 1.1 service containing all tags needed, you just have to propertly fill all generated types with fields required by your service.

It is very useful when you designing new system and need to create a lot of WSDLs. You may just generate them with this script, and then complete them manually or import them into an application like Enterprise Architect.
Generated WSDL will contain one service with as much operations as you specify in command line.
All operations are request-reply wrapped document/literal.
Generated WSDL will be output to screen, so you have to > it to some file.

Usage:
------
`wsdl_generator.pl [options] <basename> <targetNamespace> [<operation1> <operation2> ...]`
* `<basename>` is a name which will be used as a base for generating all other names. So servicese will be called `<basename>Service`, binding `<basename>Binding`, operations will be `<operation1><basename>`, etc.
* `<targetnamespace>` is a namespace used in elements of generated WSDL
If operation list is omitted, then it defaults to one operation named "Get"

Options:
--------
-v or --verbose be verbose. All messages will be written as HTML comments, so if you redirected output in file, it is safe.
--nofaults do not generate fault contracts
--exclude_basename do not complete operation names with basename, so if you specified operation Put in command line it will be called Put in WSDL, instead of `Put<basename>`

Example:
--------
`wsdl_generator.pl Test http://test.localhost/`
Will generate service called TestService in namespace http://test.localhost/ located at http://test.localhost/TestServiceю It will have one operation named GetTest
