#!/usr/bin/perl
#
# (c) Andrey Semenyuk 2014
# see http://github.com/andrrey/wsdl_generator
# This script will generate WSDL 1.1 service containing all tags needed.
# You just have to propertly fill all types with fields required by your service. 
#

sub help_banner{
	print "This script will generate WSDL 1.1 service containing all tags needed.\n";
	print "You just have to propertly complete all types with fields required by your service.\n";
	print "Usage:\t$0 <basename> <targetNamespace>\n";
	print "Example:\t$0 Test http://test.localhost/\n";
	print "\tWill generate service called TestService in namespace http://test.localhost/ located at http://test.localhost/TestService\n";
	die "\n";
}

$basename = shift or help_banner;
$targetNamespace = shift or help_banner;

$wsdlDefinitionsName = "${basename}WSDLComponent";
$serviceName = "${basename}Service";
$portName = "${basename}Port";
$bindingName = "${basename}SOAPBinding";
$serviceLocation = $targetNamespace . $serviceName;
$portTypeName = $portType . "Type";

$operationGetName = "Get" . $basename;
$operationGetURI = $targetNamespace . "actions/" . $operationGetName;
$operationGetInputName  = $operationGetName . "Req";
$operationGetOutputName = $operationGetName . "Rep";
$operationGetFaultName  = $operationGetName . "Fault";
$operationGetInputMsgName  = $operationGetName . "MsgRequest";
$operationGetOutputMsgName = $operationGetName . "MsgResponse";
$operationGetFaultMsgName  = $operationGetName . "MsgFault";
$operationGetInputElement  = $operationGetName . "RequestElem";
$operationGetOutputElement = $operationGetName . "ResponseElem";
$operationGetFaultElement  = $operationGetName . "FaultElem";
$operationGetInputElemType  = $operationGetInputElement . "_T"; 
$operationGetOutputElemType = $operationGetOutputElement . "_T"; 
$operationGetFaultElemType  = $operationGetFaultElement . "_T"; 

print <<END_OF_WSDL_TEMPLATE;
<?xml version="1.0" encoding="windows-1252"?>
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
    		<xs:complexType name="operationGetInputElemType">
    		</xs:complexType>
    		<xs:complexType name="operationGetOutputElemType">
    		</xs:complexType>
    		<xs:complexType name="operationGetFaultElemType">
    		</xs:complexType>
    		<xs:element name="$operationGetInputElement" type="s1:operationGetInputElemType"/>
    		<xs:element name="$operationGetOutputElement" type="s1:operationGetOutputElemType"/>
    		<xs:element name="$operationGetFaultElement" type="s1:operationGetFaultElemType"/>
    	</xs:schema>
    </wsdl:types>

    <wsdl:message name="$operationGetInputMsgName">
    	<wsdl:part name="body" type="tns:$operationGetInputElement"/>
    </wsdl:message>
    <wsdl:message name="$operationGetOutputMsgName">
    	<wsdl:part name="body" type="tns:$operationGetOutputElement"/>
    </wsdl:message>
    <wsdl:message name="$operationGetFaultMsgName">
    	<wsdl:part name="body" type="tns:$operationGetFaultElement"/>
    </wsdl:message>

    <wsdl:portType name="$portTypeName">
    	<wsdl:operation name="$operationGetName">
    		<wsdl:input name="$operationGetInputName" message="tns:$operationGetInputMsgName"/>
    		<wsdl:output name="$operationGetOutputName" message="tns:$operationGetOutputMsgName"/>
    		<wsdl:fault name="$operationGetFaultName" message="tns:$operationGetFaultMsgName"/>
    	</wsdl:operation>
    </wsdl:portType>

    <wsdl:binding name="$bindingName" type="tns:$portTypeName">
    	<soap:binding style="document" transport="http://schemas.xmlsoap.org/soap/http"/>
    	<wsdl:operation name="$operationGetName">
    		<soap:operation soapAction="$operationGetURI" style="document"/>
            <wsdl:input name="$operationGetInputName">
                <soap:body use="literal"/>
            </wsdl:input>
            <wsdl:output name="$operationGetOutputName">
                <soap:body use="literal"/>
            </wsdl:output>
            <wsdl:fault name="$operationGetFaultName">
                <soap:fault name="$operationGetFaultName" use="literal"/>
            </wsdl:fault>
    	</wsdl:operation>
    </wsdl:binding>

	<wsdl:service name="$serviceName">	    
	    <wsdl:port name="$portName" binding="tns:$bindingName">
            <soap:address location="$serviceLocation"/>
        </wsdl:port>
	</wsdl:service>
</wsdl:definitions>
END_OF_WSDL_TEMPLATE
