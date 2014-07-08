#!/usr/bin/perl
#
$version_major = 1;
$version_minor = 1;
#
# (c) Andrey Semenyuk 2014
# see http://github.com/andrrey/wsdl_generator
# This script will generate WSDL 1.1 service containing all tags needed.
# You just have to propertly fill all types with fields required by your service. 
#

use Getopt::Long;

sub version_banner{
    print "WSDL Generator version $version_major.$version_minor\n";
}

sub help_banner{
    version_banner;
	print "This script will generate WSDL 1.1 service containing all tags needed.\n";
	print "You just have to propertly complete all generated types with fields\nrequired by your service.\n";
	print "Usage:\t$0 [options] <basename> <targetNamespace> [<operation1> <operation2> <operation3> ...]\n";
	print "If operation list is omitted, then it defaults to one operation named \"Get\"\n";
    print "\nOptions:\n\t-v or --verbose\tbe verbose. All messages will be written as HTML comments\n";
    print "\t--nofaults\tdo not generate fault contracts\n";
    print "\t--exclude_basename\tdo not complete operation names with basename\n";
	print "\nExample:\t$0 Test http://test.localhost/\n";
	print "\tWill generate service called TestService in namespace http://test.localhost/ located at http://test.localhost/TestService\n";
    print "\tIt will have one operation named GetTest";
	die("\n");
}

$verbose = 0;
$faults = 1;
$exclude_basename = 0;

Getopt::Long::Configure ('bundling');
GetOptions('v|verbose' => \$verbose, 'faults!' => \$faults, 'exclude_basename' => \$exclude_basename);

$basename = shift or help_banner;
$targetNamespace = shift or help_banner;
#target namespace must be ended with / char.
if(substr($targetNamespace, -1, 1) ne "/") {$targetNamespace = $targetNamespace . "/";}

my @ops;
$op = shift || "Get";
while (defined $op) {
 	push(@ops, $op);
 	$op = shift;
 }

$wsdlDefinitionsName = "${basename}WSDLComponent";
$serviceName = "${basename}Service";
$portName = "${basename}Port";
$bindingName = "${basename}SOAPBinding";
$serviceLocation = $targetNamespace . $serviceName;
$portTypeName = $portName . "Type";

@data = ();

foreach $operation (@ops){
	my %hash;
    if($verbose) {print "<!-- Operation $operation -->\n";}
    if($exclude_basename) {$operationName = $operation;}
	else {$operationName = $operation . $basename;}
	$hash{operationName} = $operationName;
	$hash{operationURI} = $targetNamespace . "actions/" . $operationName;
	$hash{operationInputName}= $operationName . "Req";
	$hash{operationOutputName} = $operationName . "Rep";
	$hash{operationFaultName}  = $operationName . "Fault";
	$hash{operationInputMsgName}  = $operationName . "MsgRequest";
	$hash{operationOutputMsgName} = $operationName . "MsgResponse";
	$hash{operationFaultMsgName}  = $operationName . "MsgFault";
	$operationInputElement  = $operationName . "RequestElem";
	$hash{operationInputElement}  = $operationInputElement;
	$operationOutputElement = $operationName . "ResponseElem";
	$hash{operationOutputElement} = $operationOutputElement;
	$operationFaultElement  = $operationName . "FaultElem";
	$hash{operationFaultElement}  = $operationFaultElement;
	$hash{operationInputElemType}  = $operationInputElement . "_T"; 
	$hash{operationOutputElemType} = $operationOutputElement . "_T"; 
	$hash{operationFaultElemType}  = $operationFaultElement . "_T"; 
	push(@data, \%hash);
}

print <<TEMPLATE_START_WSDL;
<?xml version="1.0"?>
<!-- Generated with WSDL Generator, see http://github.com/andrrey/wsdl_generator -->
<wsdl:definitions name="$wsdlDefinitionsName" targetNamespace="$targetNamespace"
	xmlns:tns="$targetNamespace"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
	xmlns:http="http://schemas.xmlsoap.org/wsdl/http/"
	xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/"
	xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">
    <wsdl:types>
    	<xs:schema targetNamespace="$targetNamespace"
    		xmlns:xs="http://www.w3.org/2001/XMLSchema"
    		xmlns:s1="$targetNamespace">
TEMPLATE_START_WSDL

for $i (0 .. $#data){
	$here = <<TEMPLATE_TYPES;
    		<xs:complexType name="$data[$i]{operationInputElemType}">
    		</xs:complexType>
    		<xs:complexType name="$data[$i]{operationOutputElemType}">
    		</xs:complexType>
    		<xs:element name="$data[$i]{operationInputElement}" type="s1:$data[$i]{operationInputElemType}"/>
    		<xs:element name="$data[$i]{operationOutputElement}" type="s1:$data[$i]{operationOutputElemType}"/>
TEMPLATE_TYPES
    $here_fault = <<TEMPLATE_FAULT_TYPES;
            <xs:complexType name="$data[$i]{operationFaultElemType}">
            </xs:complexType>
            <xs:element name="$data[$i]{operationFaultElement}" type="s1:$data[$i]{operationFaultElemType}"/>
TEMPLATE_FAULT_TYPES
	print $here . "\n";
    if($faults) {print $here_fault . "\n";}
}

print "   	</xs:schema>\n\t</wsdl:types>\n";

for $i (0 .. $#data){
	$here = <<TEMPLATE_MESSAGES;
    <wsdl:message name="$data[$i]{operationInputMsgName}">
    	<wsdl:part name="body" element="tns:$data[$i]{operationInputElement}"/>
    </wsdl:message>
    <wsdl:message name="$data[$i]{operationOutputMsgName}">
    	<wsdl:part name="body" element="tns:$data[$i]{operationOutputElement}"/>
    </wsdl:message>
TEMPLATE_MESSAGES
    $here_fault = <<TEMPLATE_FAULT_MESSAGES;
    <wsdl:message name="$data[$i]{operationFaultMsgName}">
        <wsdl:part name="body" element="tns:$data[$i]{operationFaultElement}"/>
    </wsdl:message>
TEMPLATE_FAULT_MESSAGES
	print $here . "\n";
    if($faults) {print $here_fault . "\n";}
}

print"    <wsdl:portType name=\"$portTypeName\">\n";

for $i (0 .. $#data){
	$here =<<TEMPLATE_OPERATIONS;
    	<wsdl:operation name="$data[$i]{operationName}">
    		<wsdl:input name="$data[$i]{operationInputName}" message="tns:$data[$i]{operationInputMsgName}"/>
    		<wsdl:output name="$data[$i]{operationOutputName}" message="tns:$data[$i]{operationOutputMsgName}"/>
TEMPLATE_OPERATIONS
    $here_fault = <<TEMPLATE_FAULT_OPERATIONS;
            <wsdl:fault name="$data[$i]{operationFaultName}" message="tns:$data[$i]{operationFaultMsgName}"/>
TEMPLATE_FAULT_OPERATIONS
	print $here . "\n";
    if($faults) {print $here_fault . "\n";}
    print "     </wsdl:operation>\n";
}

print <<TEMPLATE_PORT;
    </wsdl:portType>

    <wsdl:binding name="$bindingName" type="tns:$portTypeName">
    	<soap:binding style="document" transport="http://schemas.xmlsoap.org/soap/http"/>
TEMPLATE_PORT

for $i (0 .. $#data){
	$here = <<TEMPLATE_PORT_OPS;
    	<wsdl:operation name="$data[$i]{operationName}">
    		<soap:operation soapAction="$data[$i]{operationURI}" style="document"/>
            <wsdl:input name="$data[$i]{operationInputName}">
                <soap:body use="literal"/>
            </wsdl:input>
            <wsdl:output name="$data[$i]{operationOutputName}">
                <soap:body use="literal"/>
            </wsdl:output>
TEMPLATE_PORT_OPS
    $here_fault = <<TEMPLATE_PORT_FAULT_OPS;
            <wsdl:fault name="$data[$i]{operationFaultName}">
                <soap:fault name="$data[$i]{operationFaultName}" use="literal"/>
            </wsdl:fault>    
TEMPLATE_PORT_FAULT_OPS
	print $here . "\n";
    if($faults) {print $here_fault . "\n";}
    print "        </wsdl:operation>\n";
}

print <<TEMPLATE_END_WSDL;
    </wsdl:binding>

	<wsdl:service name="$serviceName">	    
	    <wsdl:port name="$portName" binding="tns:$bindingName">
            <soap:address location="$serviceLocation"/>
        </wsdl:port>
	</wsdl:service>
</wsdl:definitions>
TEMPLATE_END_WSDL
