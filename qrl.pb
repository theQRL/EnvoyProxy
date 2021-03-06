
�|
google/api/http.proto
google.api"y
Http*
rules (2.google.api.HttpRuleRrulesE
fully_decode_reserved_expansion (RfullyDecodeReservedExpansion"�
HttpRule
selector (	Rselector
get (	H Rget
put (	H Rput
post (	H Rpost
delete (	H Rdelete
patch (	H Rpatch7
custom (2.google.api.CustomHttpPatternH Rcustom
body (	Rbody#
response_body (	RresponseBodyE
additional_bindings (2.google.api.HttpRuleRadditionalBindingsB	
pattern";
CustomHttpPattern
kind (	Rkind
path (	RpathBj
com.google.apiB	HttpProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations��GAPIJ�v
 �
�
 2� Copyright 2019 Google LLC.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.





 

�  

� 

�  

�  

� 

 X

� X

�

� 

� 

�W

 "

� "

�

� 

� 

�!

 *

� *

�

� 

� 

�)

 '

� '

�

� 

� 

�&

 "

� "

�

� 

� 

�!
�
  *� Defines the HTTP configuration for an API service. It contains a list of
 [HttpRule][google.api.HttpRule], each specifying the mapping of an RPC method
 to one or more HTTP REST API methods.



 
�
  !� A list of HTTP configuration rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


  !


  !

  !

  !
�
 )+� When set to true, URL path parameters will be fully URI-decoded except in
 cases of single segment matches in reserved expansion, where "%2F" will be
 left encoded.

 The default behavior is to not decode RFC 6570 reserved characters in multi
 segment matches.


 )!

 )

 )&

 ))*
�S
� ��S # gRPC Transcoding

 gRPC Transcoding is a feature for mapping between a gRPC method and one or
 more HTTP REST endpoints. It allows developers to build a single API service
 that supports both gRPC APIs and REST APIs. Many systems, including [Google
 APIs](https://github.com/googleapis/googleapis),
 [Cloud Endpoints](https://cloud.google.com/endpoints), [gRPC
 Gateway](https://github.com/grpc-ecosystem/grpc-gateway),
 and [Envoy](https://github.com/envoyproxy/envoy) proxy support this feature
 and use it for large scale production services.

 `HttpRule` defines the schema of the gRPC/REST mapping. The mapping specifies
 how different portions of the gRPC request message are mapped to the URL
 path, URL query parameters, and HTTP request body. It also controls how the
 gRPC response message is mapped to the HTTP response body. `HttpRule` is
 typically specified as an `google.api.http` annotation on the gRPC method.

 Each mapping specifies a URL path template and an HTTP method. The path
 template may refer to one or more fields in the gRPC request message, as long
 as each field is a non-repeated field with a primitive (non-message) type.
 The path template controls how fields of the request message are mapped to
 the URL path.

 Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get: "/v1/{name=messages/*}"
         };
       }
     }
     message GetMessageRequest {
       string name = 1; // Mapped to URL path.
     }
     message Message {
       string text = 1; // The resource content.
     }

 This enables an HTTP REST to gRPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456`  | `GetMessage(name: "messages/123456")`

 Any fields in the request message which are not bound by the path template
 automatically become HTTP query parameters if there is no HTTP request body.
 For example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get:"/v1/messages/{message_id}"
         };
       }
     }
     message GetMessageRequest {
       message SubMessage {
         string subfield = 1;
       }
       string message_id = 1; // Mapped to URL path.
       int64 revision = 2;    // Mapped to URL query parameter `revision`.
       SubMessage sub = 3;    // Mapped to URL query parameter `sub.subfield`.
     }

 This enables a HTTP JSON to RPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456?revision=2&sub.subfield=foo` |
 `GetMessage(message_id: "123456" revision: 2 sub: SubMessage(subfield:
 "foo"))`

 Note that fields which are mapped to URL query parameters must have a
 primitive type or a repeated primitive type or a non-repeated message type.
 In the case of a repeated type, the parameter can be repeated in the URL
 as `...?param=A&param=B`. In the case of a message type, each field of the
 message is mapped to a separate parameter, such as
 `...?foo.a=A&foo.b=B&foo.c=C`.

 For HTTP methods that allow a request body, the `body` field
 specifies the mapping. Consider a REST update method on the
 message resource collection:

     service Messaging {
       rpc UpdateMessage(UpdateMessageRequest) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "message"
         };
       }
     }
     message UpdateMessageRequest {
       string message_id = 1; // mapped to the URL
       Message message = 2;   // mapped to the body
     }

 The following HTTP JSON to RPC mapping is enabled, where the
 representation of the JSON in the request body is determined by
 protos JSON encoding:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" message { text: "Hi!" })`

 The special name `*` can be used in the body mapping to define that
 every field not bound by the path template should be mapped to the
 request body.  This enables the following alternative definition of
 the update method:

     service Messaging {
       rpc UpdateMessage(Message) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "*"
         };
       }
     }
     message Message {
       string message_id = 1;
       string text = 2;
     }


 The following HTTP JSON to RPC mapping is enabled:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" text: "Hi!")`

 Note that when using `*` in the body mapping, it is not possible to
 have HTTP parameters, as all fields not bound by the path end in
 the body. This makes this option more rarely used in practice when
 defining REST APIs. The common usage of `*` is in custom methods
 which don't use the URL at all for transferring data.

 It is possible to define multiple HTTP methods for one RPC by using
 the `additional_bindings` option. Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
           get: "/v1/messages/{message_id}"
           additional_bindings {
             get: "/v1/users/{user_id}/messages/{message_id}"
           }
         };
       }
     }
     message GetMessageRequest {
       string message_id = 1;
       string user_id = 2;
     }

 This enables the following two alternative HTTP JSON to RPC mappings:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456` | `GetMessage(message_id: "123456")`
 `GET /v1/users/me/messages/123456` | `GetMessage(user_id: "me" message_id:
 "123456")`

 ## Rules for HTTP mapping

 1. Leaf request fields (recursive expansion nested messages in the request
    message) are classified into three categories:
    - Fields referred by the path template. They are passed via the URL path.
    - Fields referred by the [HttpRule.body][google.api.HttpRule.body]. They are passed via the HTTP
      request body.
    - All other fields are passed via the URL query parameters, and the
      parameter name is the field path in the request message. A repeated
      field can be represented as multiple query parameters under the same
      name.
  2. If [HttpRule.body][google.api.HttpRule.body] is "*", there is no URL query parameter, all fields
     are passed via URL path and HTTP request body.
  3. If [HttpRule.body][google.api.HttpRule.body] is omitted, there is no HTTP request body, all
     fields are passed via URL path and URL query parameters.

 ### Path template syntax

     Template = "/" Segments [ Verb ] ;
     Segments = Segment { "/" Segment } ;
     Segment  = "*" | "**" | LITERAL | Variable ;
     Variable = "{" FieldPath [ "=" Segments ] "}" ;
     FieldPath = IDENT { "." IDENT } ;
     Verb     = ":" LITERAL ;

 The syntax `*` matches a single URL path segment. The syntax `**` matches
 zero or more URL path segments, which must be the last part of the URL path
 except the `Verb`.

 The syntax `Variable` matches part of the URL path as specified by its
 template. A variable template must not contain other variables. If a variable
 matches a single path segment, its template may be omitted, e.g. `{var}`
 is equivalent to `{var=*}`.

 The syntax `LITERAL` matches literal text in the URL path. If the `LITERAL`
 contains any reserved character, such characters should be percent-encoded
 before the matching.

 If a variable contains exactly one path segment, such as `"{var}"` or
 `"{var=*}"`, when such a variable is expanded into a URL path on the client
 side, all characters except `[-_.~0-9a-zA-Z]` are percent-encoded. The
 server side does the reverse decoding. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{var}`.

 If a variable contains multiple path segments, such as `"{var=foo/*}"`
 or `"{var=**}"`, when such a variable is expanded into a URL path on the
 client side, all characters except `[-_.~/0-9a-zA-Z]` are percent-encoded.
 The server side does the reverse decoding, except "%2F" and "%2f" are left
 unchanged. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{+var}`.

 ## Using gRPC API Service Configuration

 gRPC API Service Configuration (service config) is a configuration language
 for configuring a gRPC service to become a user-facing product. The
 service config is simply the YAML representation of the `google.api.Service`
 proto message.

 As an alternative to annotating your proto file, you can configure gRPC
 transcoding in your service config YAML files. You do this by specifying a
 `HttpRule` that maps the gRPC method to a REST endpoint, achieving the same
 effect as the proto annotation. This can be particularly useful if you
 have a proto that is reused in multiple services. Note that any transcoding
 specified in the service config will override any matching transcoding
 configuration in the proto.

 Example:

     http:
       rules:
         # Selects a gRPC method and applies HttpRule to it.
         - selector: example.v1.Messaging.GetMessage
           get: /v1/messages/{message_id}/{sub.subfield}

 ## Special notes

 When gRPC Transcoding is used to map a gRPC to JSON REST endpoints, the
 proto to JSON conversion must follow the [proto3
 specification](https://developers.google.com/protocol-buffers/docs/proto3#json).

 While the single segment variable follows the semantics of
 [RFC 6570](https://tools.ietf.org/html/rfc6570) Section 3.2.2 Simple String
 Expansion, the multi segment variable **does not** follow RFC 6570 Section
 3.2.3 Reserved Expansion. The reason is that the Reserved Expansion
 does not expand special characters like `?` and `#`, which would lead
 to invalid URLs. As the result, gRPC Transcoding uses a custom encoding
 for multi segment variables.

 The path variables **must not** refer to any repeated or mapped field,
 because client libraries are not capable of handling such variable expansion.

 The path variables **must not** capture the leading "/" character. The reason
 is that the most common use case "{var}" does not capture the leading "/"
 character. For consistency, all path variables must share the same behavior.

 Repeated message fields must not be mapped to URL query parameters, because
 no client library can support such complicated mapping.

 If an API needs to use a JSON array for request or response body, it can map
 the request or response body to a repeated field. However, some gRPC
 Transcoding implementations may not support this feature.


�
�
 � Selects a method to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 ��

 �

 �	

 �
�
 ��� Determines the URL pattern is matched by this rules. This pattern can be
 used with any of the {get|put|post|delete|patch} methods. A custom method
 can be defined using the 'custom' field.


 �
\
�N Maps to HTTP GET. Used for listing and getting information about
 resources.


�


�

�
@
�2 Maps to HTTP PUT. Used for replacing a resource.


�


�

�
X
�J Maps to HTTP POST. Used for creating a resource or performing an action.


�


�

�
B
�4 Maps to HTTP DELETE. Used for deleting a resource.


�


�

�
A
�3 Maps to HTTP PATCH. Used for updating a resource.


�


�

�
�
�!� The custom pattern is used for specifying an HTTP method that is not
 included in the `pattern` field, such as HEAD, or "*" to leave the
 HTTP method unspecified for this rule. The wild-card rule is useful
 for services that provide content to Web (HTML) clients.


�

�

� 
�
�� The name of the request field whose value is mapped to the HTTP request
 body, or `*` for mapping all request fields not captured by the path
 pattern to the HTTP body, or omitted for not having any HTTP request body.

 NOTE: the referred field must be present at the top-level of the request
 message type.


��

�

�	

�
�
�� Optional. The name of the response field whose value is mapped to the HTTP
 response body. When omitted, the entire response message will be used
 as the HTTP response body.

 NOTE: The referred field must be present at the top-level of the response
 message type.


��

�

�	

�
�
	�-� Additional HTTP bindings for the selector. Nested bindings must
 not contain an `additional_bindings` field themselves (that is,
 the nesting may only be one level deep).


	�


	�

	�'

	�*,
G
� �9 A custom pattern is used for defining custom HTTP verb.


�
2
 �$ The name of this custom HTTP verb.


 ��

 �

 �	

 �
5
�' The path matched by this custom verb.


��

�

�	

�bproto3
��
 google/protobuf/descriptor.protogoogle.protobuf"M
FileDescriptorSet8
file (2$.google.protobuf.FileDescriptorProtoRfile"�
FileDescriptorProto
name (	Rname
package (	Rpackage

dependency (	R
dependency+
public_dependency
 (RpublicDependency'
weak_dependency (RweakDependencyC
message_type (2 .google.protobuf.DescriptorProtoRmessageTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeA
service (2'.google.protobuf.ServiceDescriptorProtoRserviceC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extension6
options (2.google.protobuf.FileOptionsRoptionsI
source_code_info	 (2.google.protobuf.SourceCodeInfoRsourceCodeInfo
syntax (	Rsyntax"�
DescriptorProto
name (	Rname;
field (2%.google.protobuf.FieldDescriptorProtoRfieldC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extensionA
nested_type (2 .google.protobuf.DescriptorProtoR
nestedTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeX
extension_range (2/.google.protobuf.DescriptorProto.ExtensionRangeRextensionRangeD

oneof_decl (2%.google.protobuf.OneofDescriptorProtoR	oneofDecl9
options (2.google.protobuf.MessageOptionsRoptionsU
reserved_range	 (2..google.protobuf.DescriptorProto.ReservedRangeRreservedRange#
reserved_name
 (	RreservedNamez
ExtensionRange
start (Rstart
end (Rend@
options (2&.google.protobuf.ExtensionRangeOptionsRoptions7
ReservedRange
start (Rstart
end (Rend"|
ExtensionRangeOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
FieldDescriptorProto
name (	Rname
number (RnumberA
label (2+.google.protobuf.FieldDescriptorProto.LabelRlabel>
type (2*.google.protobuf.FieldDescriptorProto.TypeRtype
	type_name (	RtypeName
extendee (	Rextendee#
default_value (	RdefaultValue
oneof_index	 (R
oneofIndex
	json_name
 (	RjsonName7
options (2.google.protobuf.FieldOptionsRoptions"�
Type
TYPE_DOUBLE

TYPE_FLOAT

TYPE_INT64
TYPE_UINT64

TYPE_INT32
TYPE_FIXED64
TYPE_FIXED32
	TYPE_BOOL
TYPE_STRING	

TYPE_GROUP

TYPE_MESSAGE

TYPE_BYTES
TYPE_UINT32
	TYPE_ENUM
TYPE_SFIXED32
TYPE_SFIXED64
TYPE_SINT32
TYPE_SINT64"C
Label
LABEL_OPTIONAL
LABEL_REQUIRED
LABEL_REPEATED"c
OneofDescriptorProto
name (	Rname7
options (2.google.protobuf.OneofOptionsRoptions"�
EnumDescriptorProto
name (	Rname?
value (2).google.protobuf.EnumValueDescriptorProtoRvalue6
options (2.google.protobuf.EnumOptionsRoptions]
reserved_range (26.google.protobuf.EnumDescriptorProto.EnumReservedRangeRreservedRange#
reserved_name (	RreservedName;
EnumReservedRange
start (Rstart
end (Rend"�
EnumValueDescriptorProto
name (	Rname
number (Rnumber;
options (2!.google.protobuf.EnumValueOptionsRoptions"�
ServiceDescriptorProto
name (	Rname>
method (2&.google.protobuf.MethodDescriptorProtoRmethod9
options (2.google.protobuf.ServiceOptionsRoptions"�
MethodDescriptorProto
name (	Rname

input_type (	R	inputType
output_type (	R
outputType8
options (2.google.protobuf.MethodOptionsRoptions0
client_streaming (:falseRclientStreaming0
server_streaming (:falseRserverStreaming"�
FileOptions!
java_package (	RjavaPackage0
java_outer_classname (	RjavaOuterClassname5
java_multiple_files
 (:falseRjavaMultipleFilesD
java_generate_equals_and_hash (BRjavaGenerateEqualsAndHash:
java_string_check_utf8 (:falseRjavaStringCheckUtf8S
optimize_for	 (2).google.protobuf.FileOptions.OptimizeMode:SPEEDRoptimizeFor

go_package (	R	goPackage5
cc_generic_services (:falseRccGenericServices9
java_generic_services (:falseRjavaGenericServices5
py_generic_services (:falseRpyGenericServices7
php_generic_services* (:falseRphpGenericServices%

deprecated (:falseR
deprecated/
cc_enable_arenas (:falseRccEnableArenas*
objc_class_prefix$ (	RobjcClassPrefix)
csharp_namespace% (	RcsharpNamespace!
swift_prefix' (	RswiftPrefix(
php_class_prefix( (	RphpClassPrefix#
php_namespace) (	RphpNamespaceX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption":
OptimizeMode	
SPEED
	CODE_SIZE
LITE_RUNTIME*	�����J&'"�
MessageOptions<
message_set_wire_format (:falseRmessageSetWireFormatL
no_standard_descriptor_accessor (:falseRnoStandardDescriptorAccessor%

deprecated (:falseR
deprecated
	map_entry (RmapEntryX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J	J	
"�
FieldOptionsA
ctype (2#.google.protobuf.FieldOptions.CType:STRINGRctype
packed (RpackedG
jstype (2$.google.protobuf.FieldOptions.JSType:	JS_NORMALRjstype
lazy (:falseRlazy%

deprecated (:falseR
deprecated
weak
 (:falseRweakX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"/
CType

STRING 
CORD
STRING_PIECE"5
JSType
	JS_NORMAL 
	JS_STRING
	JS_NUMBER*	�����J"s
OneofOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
EnumOptions
allow_alias (R
allowAlias%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J"�
EnumValueOptions%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
ServiceOptions%

deprecated! (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
MethodOptions%

deprecated! (:falseR
deprecatedq
idempotency_level" (2/.google.protobuf.MethodOptions.IdempotencyLevel:IDEMPOTENCY_UNKNOWNRidempotencyLevelX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"P
IdempotencyLevel
IDEMPOTENCY_UNKNOWN 
NO_SIDE_EFFECTS

IDEMPOTENT*	�����"�
UninterpretedOptionA
name (2-.google.protobuf.UninterpretedOption.NamePartRname)
identifier_value (	RidentifierValue,
positive_int_value (RpositiveIntValue,
negative_int_value (RnegativeIntValue!
double_value (RdoubleValue!
string_value (RstringValue'
aggregate_value (	RaggregateValueJ
NamePart
	name_part (	RnamePart!
is_extension (RisExtension"�
SourceCodeInfoD
location (2(.google.protobuf.SourceCodeInfo.LocationRlocation�
Location
path (BRpath
span (BRspan)
leading_comments (	RleadingComments+
trailing_comments (	RtrailingComments:
leading_detached_comments (	RleadingDetachedComments"�
GeneratedCodeInfoM

annotation (2-.google.protobuf.GeneratedCodeInfo.AnnotationR
annotationm

Annotation
path (BRpath
source_file (	R
sourceFile
begin (Rbegin
end (RendB�
com.google.protobufBDescriptorProtosHZ>github.com/golang/protobuf/protoc-gen-go/descriptor;descriptor��GPB�Google.Protobuf.ReflectionJ��
' �
�
' 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
2� Author: kenton@google.com (Kenton Varda)
  Based on original Protocol Buffers design by
  Sanjay Ghemawat, Jeff Dean, and others.

 The messages in this file describe the definitions found in .proto files.
 A valid .proto file can be translated directly to a FileDescriptorProto
 without any other information (e.g. without reading its imports).


)

* U

� * U

� *

�  *

�  *

� *T

+ ,

�+ ,

�+

� +

� +

�++

, 1

�, 1

�,

� ,

� ,

�,0

- 7

�- 7

�-

� -

� -

�-6

. !

�. !

�.

� .

� .

�. 

/ 

�/ 

�/

� /

� /

�/

3 
�
�3 t descriptor.proto must be optimized for speed because reflection-based
 algorithms don't work during bootstrapping.


�3

� 3

� 3

�3
j
 7 9^ The protocol compiler can output a FileDescriptorSet containing the .proto
 files it parses.



 7

  8(

  8


  8

  8#

  8&'
/
< Y# Describes a complete .proto file.



<
9
 =", file name, relative to root of source tree


 =


 =

 =

 =
*
>" e.g. "foo", "foo.bar", etc.


>


>

>

>
4
A!' Names of files imported by this file.


A


A

A

A 
Q
C(D Indexes of the public imported files in the dependency list above.


C


C

C"

C%'
z
F&m Indexes of the weak imported files in the dependency list.
 For Google-internal migration only. Do not use.


F


F

F 

F#%
6
I,) All top-level definitions in this file.


I


I

I'

I*+

J-

J


J

J(

J+,

K.

K


K!

K")

K,-

L.

L


L

L )

L,-

	N#

	N


	N

	N

	N!"
�

T/� This field contains optional information about the original source code.
 You may safely remove this entire field without harming runtime
 functionality of the descriptors -- the information is needed only by
 development tools.



T



T


T*


T-.
]
XP The syntax of the proto file.
 The supported values are "proto2" and "proto3".


X


X

X

X
'
\ | Describes a message type.



\

 ]

 ]


 ]

 ]

 ]

_*

_


_

_ %

_()

`.

`


`

` )

`,-

b+

b


b

b&

b)*

c-

c


c

c(

c+,

 ej

 e


  f

  f

  f

  f

  f

 g

 g

 g

 g

 g

 i/

 i

 i"

 i#*

 i-.

k.

k


k

k)

k,-

m/

m


m

m *

m-.

o&

o


o

o!

o$%
�
tw� Range of reserved tag numbers. Reserved tag numbers may not be used by
 fields or extension ranges in the same message. Reserved ranges may
 not overlap.


t


 u" Inclusive.


 u

 u

 u

 u

v" Exclusive.


v

v

v

v

x,

x


x

x'

x*+
�
	{%u Reserved field names, which may not be used by fields in the same message.
 A given name may only be reserved once.


	{


	{

	{

	{"$

~ �


~
O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
3
� �% Describes a field within a message.


�

 ��

 �
S
  �C 0 is reserved for errors.
 Order is weird for historical reasons.


  �

  �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
 negative values are likely.


 �

 �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
 negative values are likely.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
�
 	�� Tag-delimited aggregate.
 Group type is deprecated and not supported in proto3. However, Proto3
 implementations should still be able to parse the group wire format and
 treat group fields as unknown fields.


 	�

 	�
-
 
�" Length-delimited aggregate.


 
�

 
�
#
 � New in version 2.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
'
 �" Uses ZigZag encoding.


 �

 �
'
 �" Uses ZigZag encoding.


 �

 �

��

�
*
 � 0 is reserved for errors


 �

 �

�

�

�

�

�

�

 �

 �


 �

 �

 �

�

�


�

�

�

�

�


�

�

�
�
�� If type_name is set, this need not be set.  If both this and type_name
 are set, this must be one of TYPE_ENUM, TYPE_MESSAGE or TYPE_GROUP.


�


�

�

�
�
� � For message and enum types, this is the name of the type.  If the name
 starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
 rules are used to find the type (i.e. first the nested types within this
 message are searched, then within the parent, on up to the root
 namespace).


�


�

�

�
~
�p For extensions, this is the name of the type being extended.  It is
 resolved in the same manner as type_name.


�


�

�

�
�
�$� For numeric types, contains the original text representation of the value.
 For booleans, "true" or "false".
 For strings, contains the default text contents (not escaped in any way).
 For bytes, contains the C escaped value.  All bytes >= 128 are escaped.
 TODO(kenton):  Base-64 encode?


�


�

�

�"#
�
�!v If set, gives the index of a oneof in the containing type's oneof_decl
 list.  This field is a member of that oneof.


�


�

�

� 
�
�!� JSON name of this field. The value is set by protocol compiler. If the
 user has set a "json_name" option on this field, that option's value
 will be used. Otherwise, it's deduced from the field's name by converting
 it to camelCase.


�


�

�

� 

	�$

	�


	�

	�

	�"#
"
� � Describes a oneof.


�

 �

 �


 �

 �

 �

�$

�


�

�

�"#
'
� � Describes an enum type.


�

 �

 �


 �

 �

 �

�.

�


�#

�$)

�,-

�#

�


�

�

�!"
�
 ��� Range of reserved numeric values. Reserved values may not be used by
 entries in the same enum. Reserved ranges may not overlap.

 Note that this is distinct from DescriptorProto.ReservedRange in that it
 is inclusive such that it can appropriately represent the entire int32
 domain.


 �


  �" Inclusive.


  �

  �

  �

  �

 �" Inclusive.


 �

 �

 �

 �
�
�0� Range of reserved numeric values. Reserved numeric values may not be used
 by enum values in the same enum declaration. Reserved ranges may not
 overlap.


�


�

�+

�./
l
�$^ Reserved enum value names, which may not be reused. A given name may only
 be reserved once.


�


�

�

�"#
1
� �# Describes a value within an enum.


� 

 �

 �


 �

 �

 �

�

�


�

�

�

�(

�


�

�#

�&'
$
� � Describes a service.


�

 �

 �


 �

 �

 �

�,

�


� 

�!'

�*+

�&

�


�

�!

�$%
0
	� �" Describes a method of a service.


	�

	 �

	 �


	 �

	 �

	 �
�
	�!� Input and output type names.  These are resolved in the same way as
 FieldDescriptorProto.type_name, but must refer to a message type.


	�


	�

	�

	� 

	�"

	�


	�

	�

	� !

	�%

	�


	�

	� 

	�#$
E
	�57 Identifies if client streams multiple client messages


	�


	�

	� 

	�#$

	�%4

	�.3
E
	�57 Identifies if server streams multiple server messages


	�


	�

	� 

	�#$

	�%4

	�.3
�

� �2N ===================================================================
 Options
2� Each of the definitions above may have "options" attached.  These are
 just annotations which may cause code to be generated slightly differently
 or may contain hints for code that manipulates protocol messages.

 Clients may define custom options as extensions of the *Options messages.
 These extensions may not yet be known at parsing time, so the parser cannot
 store the values in them.  Instead it stores them in a field in the *Options
 message called uninterpreted_option. This field must have the same name
 across all *Options messages. We then use this field to populate the
 extensions when we build a descriptor, at which point all protos have been
 parsed and so all extensions are known.

 Extension numbers for custom options may be chosen as follows:
 * For options which will only be used within a single application or
   organization, or for experimental options, use field numbers 50000
   through 99999.  It is up to you to ensure that you do not use the
   same number for multiple options.
 * For options which will be published and used publicly by multiple
   independent entities, e-mail protobuf-global-extension-registry@google.com
   to reserve extension numbers. Simply provide your project name (e.g.
   Objective-C plugin) and your project website (if available) -- there's no
   need to explain how you intend to use them. Usually you only need one
   extension number. You can declare multiple options with only one extension
   number by putting them in a sub-message. See the Custom Options section of
   the docs for examples:
   https://developers.google.com/protocol-buffers/docs/proto#options
   If this turns out to be popular, a web service will be set up
   to automatically assign option numbers.



�
�

 �#� Sets the Java package where classes generated from this .proto will be
 placed.  By default, the proto package is used, but this is often
 inappropriate because proto packages do not normally start with backwards
 domain names.



 �



 �


 �


 �!"
�

�+� If set, all the classes from the .proto file are wrapped in a single
 outer class with the given name.  This applies to both Proto1
 (equivalent to the old "--one_java_file" option) and Proto2 (where
 a .proto always translates to a single class, but you may want to
 explicitly choose the class name).



�



�


�&


�)*
�

�9� If set true, then the Java code generator will generate a separate .java
 file for each top-level message, enum, and service defined in the .proto
 file.  Thus, these types will *not* be nested inside the outer class
 named by java_outer_classname.  However, the outer class will still be
 generated to contain the file's getDescriptor() method as well as any
 top-level extensions defined in the file.



�



�


�#


�&(


�)8


�27
)

�E This option does nothing.



�



�


�-


�02


�3D


� �4C

	
� �4>



�  �4>


�  �4>

	
� �?C
�

�<� If set true, then the Java2 code generator will generate code that
 throws an exception whenever an attempt is made to assign a non-UTF-8
 byte sequence to a string field.
 Message reflection will do the same.
 However, an extension field still accepts non-UTF-8 byte sequences.
 This option has no effect on when used with the lite runtime.



�



�


�&


�)+


�,;


�5:
L

 ��< Generated classes can be optimized for speed or code size.



 �
D

  �"4 Generate complete code for parsing, serialization,



  �	


  �
G

 � etc.
"/ Use ReflectionOps to implement these methods.



 �


 �
G

 �"7 Generate code using MessageLite and the lite runtime.



 �


 �


�9


�



�


�$


�'(


�)8


�27
�

�"� Sets the Go package where structs generated from this .proto will be
 placed. If omitted, the Go package will be derived from the following:
   - The basename of the package import path, if provided.
   - Otherwise, the package statement in the .proto file, if present.
   - Otherwise, the basename of the .proto file, without extension.



�



�


�


�!
�

�9� Should generic services be generated in each language?  "Generic" services
 are not specific to any particular RPC system.  They are generated by the
 main code generators in each language (without additional plugins).
 Generic services were the only kind of service generation supported by
 early versions of google.protobuf.

 Generic services are now considered deprecated in favor of using plugins
 that generate code specific to your particular RPC system.  Therefore,
 these default to false.  Old code which depends on generic services should
 explicitly set them to true.



�



�


�#


�&(


�)8


�27


�;


�



�


�%


�(*


�+:


�49


	�9


	�



	�


	�#


	�&(


	�)8


	�27



�:



�




�



�$



�')



�*9



�38
�

�0� Is this file deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for everything in the file, or it will be completely ignored; in the very
 least, this is a formalization for deprecating files.



�



�


�


�


� /


�).


�6q Enables the use of arenas for the proto messages in this file. This applies
 only to generated classes for C++.



�



�


� 


�#%


�&5


�/4
�

�)� Sets the objective c class prefix which is prepended to all objective c
 generated classes from this .proto. There is no default.



�



�


�#


�&(
I

�(; Namespace for generated classes; defaults to the package.



�



�


�"


�%'
�

�$� By default Swift generators will take the proto package and CamelCase it
 replacing '.' with underscore and use that to prefix the types/symbols
 defined. When this options is provided, they will use this value instead
 to prefix the types/symbols defined.



�



�


�


�!#
~

�(p Sets the php class prefix which is prepended to all php generated classes
 from this .proto. Default is empty.



�



�


�"


�%'
�

�%� Use this option to change the namespace of php generated classes. Default
 is empty. When this option is empty, the package name will be used for
 determining the namespace.



�



�


�


�"$
|

�:n The parser stores options it doesn't recognize here.
 See the documentation for the "Options" section above.



�



�


�3


�69
�

�z Clients can define custom options in extensions of this message.
 See the documentation for the "Options" section above.



 �


 �


 �


	�


	 �


	 �


	 �

� �

�
�
 �<� Set true to use the old proto1 MessageSet wire format for extensions.
 This is provided for backwards-compatibility with the MessageSet wire
 format.  You should not use this for any other reason:  It's less
 efficient, has fewer features, and is more complicated.

 The message must be defined exactly as follows:
   message Foo {
     option message_set_wire_format = true;
     extensions 4 to max;
   }
 Note that the message cannot have any defined fields; MessageSets only
 have extensions.

 All extensions of your type must be singular messages; e.g. they cannot
 be int32s, enums, or repeated messages.

 Because this is an option, the above two restrictions are not enforced by
 the protocol compiler.


 �


 �

 �'

 �*+

 �,;

 �5:
�
�D� Disables the generation of the standard "descriptor()" accessor, which can
 conflict with a field of the same name.  This is meant to make migration
 from proto1 easier; new code should avoid fields named "descriptor".


�


�

�/

�23

�4C

�=B
�
�/� Is this message deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the message, or it will be completely ignored; in the very least,
 this is a formalization for deprecating messages.


�


�

�

�

�.

�(-
�
�� Whether the message is an automatically generated map entry type for the
 maps field.

 For maps fields:
     map<KeyType, ValueType> map_field = 1;
 The parsed descriptor looks like:
     message MapFieldEntry {
         option map_entry = true;
         optional KeyType key = 1;
         optional ValueType value = 2;
     }
     repeated MapFieldEntry map_field = 1;

 Implementations may choose not to generate the map_entry=true message, but
 use a native map in the target language to hold the keys and values.
 The reflection APIs in such implementions still need to work as
 if the field is a repeated message field.

 NOTE: Do not set the option in .proto files. Always use the maps syntax
 instead. The option should only be implicitly set by the proto compiler
 parser.


�


�

�

�
$
	�" javalite_serializable


	 �

	 �

	 �

	�" javanano_as_lite


	�

	�

	�
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �.� The ctype option instructs the C++ code generator to use a different
 representation of the field than it normally would.  See the specific
 options below.  This option is not yet implemented in the open source
 release -- sorry, we'll try to include it in a future version!


 �


 �

 �

 �

 �-

 �&,

 ��

 �

  � Default mode.


  �


  �

 �

 �

 �

 �

 �

 �
�
�� The packed option can be enabled for repeated primitive fields to enable
 a more efficient representation on the wire. Rather than repeatedly
 writing the tag and type for each element, the entire array is encoded as
 a single length-delimited blob. In proto3, only explicit setting it to
 false will avoid using packed encoding.


�


�

�

�
�
�3� The jstype option determines the JavaScript type used for values of the
 field.  The option is permitted only for 64 bit integral and fixed types
 (int64, uint64, sint64, fixed64, sfixed64).  A field with jstype JS_STRING
 is represented as JavaScript string, which avoids loss of precision that
 can happen when a large value is converted to a floating point JavaScript.
 Specifying JS_NUMBER for the jstype causes the generated JavaScript code to
 use the JavaScript "number" type.  The behavior of the default option
 JS_NORMAL is implementation dependent.

 This option is an enum to permit additional types to be added, e.g.
 goog.math.Integer.


�


�

�

�

�2

�(1

��

�
'
 � Use the default type.


 �

 �
)
� Use JavaScript strings.


�

�
)
� Use JavaScript numbers.


�

�
�
�)� Should this field be parsed lazily?  Lazy applies only to message-type
 fields.  It means that when the outer message is initially parsed, the
 inner message's contents will not be parsed but instead stored in encoded
 form.  The inner message will actually be parsed when it is first accessed.

 This is only a hint.  Implementations are free to choose whether to use
 eager or lazy parsing regardless of the value of this option.  However,
 setting this option true suggests that the protocol author believes that
 using lazy parsing on this field is worth the additional bookkeeping
 overhead typically needed to implement it.

 This option does not affect the public interface of any generated code;
 all method signatures remain the same.  Furthermore, thread-safety of the
 interface is not affected by this option; const methods remain safe to
 call from multiple threads concurrently, while non-const methods continue
 to require exclusive access.


 Note that implementations may choose not to check required fields within
 a lazy sub-message.  That is, calling IsInitialized() on the outer message
 may return true even if the inner message has missing required fields.
 This is necessary because otherwise the inner message would have to be
 parsed in order to perform the check, defeating the purpose of lazy
 parsing.  An implementation which chooses not to check required fields
 must be consistent about it.  That is, for any particular sub-message, the
 implementation must either *always* check its required fields, or *never*
 check its required fields, regardless of whether or not the message has
 been parsed.


�


�

�

�

�(

�"'
�
�/� Is this field deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for accessors, or it will be completely ignored; in the very least, this
 is a formalization for deprecating fields.


�


�

�

�

�.

�(-
?
�*1 For Google-internal migration only. Do not use.


�


�

�

�

�)

�#(
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

	�" removed jtype


	 �

	 �

	 �

� �

�
O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
`
 � R Set this option to true to allow mapping different tag names to the same
 value.


 �


 �

 �

 �
�
�/� Is this enum deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum, or it will be completely ignored; in the very least, this
 is a formalization for deprecating enums.


�


�

�

�

�.

�(-

	�" javanano_as_lite


	 �

	 �

	 �
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �/� Is this enum value deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum value, or it will be completely ignored; in the very least,
 this is a formalization for deprecating enum values.


 �


 �

 �

 �

 �.

 �(-
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �0� Is this service deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the service, or it will be completely ignored; in the very least,
 this is a formalization for deprecating services.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � /

 �).
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �0� Is this method deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the method, or it will be completely ignored; in the very least,
 this is a formalization for deprecating methods.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � /

 �).
�
 ��� Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
 or neither? HTTP based RPC implementation may choose GET verb for safe
 methods, and PUT verb for idempotent methods instead of the default POST.


 �

  �

  �

  �
$
 �" implies idempotent


 �

 �
7
 �"' idempotent, but may have side effects


 �

 �

��'

�


�

�-

�

�	&

�%
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
�
� �� A message representing a option the parser does not recognize. This only
 appears in options protos created by the compiler::Parser class.
 DescriptorPool resolves these when building Descriptor objects. Therefore,
 options protos in descriptor objects (e.g. returned by Descriptor::options(),
 or produced by Descriptor::CopyTo()) will never have UninterpretedOptions
 in them.


�
�
 ��� The name of the uninterpreted option.  Each string represents a segment in
 a dot-separated name.  is_extension is true iff a segment represents an
 extension (denoted with parentheses in options specs in .proto files).
 E.g.,{ ["foo", false], ["bar.baz", true], ["qux", false] } represents
 "foo.(bar.baz).qux".


 �


  �"

  �

  �

  �

  � !

 �#

 �

 �

 �

 �!"

 �

 �


 �

 �

 �
�
�'� The value of the uninterpreted option, in whatever type the tokenizer
 identified it as during parsing. Exactly one of these should be set.


�


�

�"

�%&

�)

�


�

�$

�'(

�(

�


�

�#

�&'

�#

�


�

�

�!"

�"

�


�

�

� !

�&

�


�

�!

�$%
�
� �j Encapsulates information about the original source file from which a
 FileDescriptorProto was generated.
2` ===================================================================
 Optional source code info


�
�
 �!� A Location identifies a piece of source code in a .proto file which
 corresponds to a particular definition.  This information is intended
 to be useful to IDEs, code indexers, documentation generators, and similar
 tools.

 For example, say we have a file like:
   message Foo {
     optional string foo = 1;
   }
 Let's look at just the field definition:
   optional string foo = 1;
   ^       ^^     ^^  ^  ^^^
   a       bc     de  f  ghi
 We have the following locations:
   span   path               represents
   [a,i)  [ 4, 0, 2, 0 ]     The whole field definition.
   [a,b)  [ 4, 0, 2, 0, 4 ]  The label (optional).
   [c,d)  [ 4, 0, 2, 0, 5 ]  The type (string).
   [e,f)  [ 4, 0, 2, 0, 1 ]  The name (foo).
   [g,h)  [ 4, 0, 2, 0, 3 ]  The number (1).

 Notes:
 - A location may refer to a repeated field itself (i.e. not to any
   particular index within it).  This is used whenever a set of elements are
   logically enclosed in a single code segment.  For example, an entire
   extend block (possibly containing multiple extension definitions) will
   have an outer location whose path refers to the "extensions" repeated
   field without an index.
 - Multiple locations may have the same path.  This happens when a single
   logical declaration is spread out across multiple places.  The most
   obvious example is the "extend" block again -- there may be multiple
   extend blocks in the same scope, each of which will have the same path.
 - A location's span is not always a subset of its parent's span.  For
   example, the "extendee" of an extension declaration appears at the
   beginning of the "extend" block and is shared by all extensions within
   the block.
 - Just because a location's span is a subset of some other location's span
   does not mean that it is a descendent.  For example, a "group" defines
   both a type and a field in a single declaration.  Thus, the locations
   corresponding to the type and field and their components will overlap.
 - Code which tries to interpret locations should probably be designed to
   ignore those that it doesn't understand, as more types of locations could
   be recorded in the future.


 �


 �

 �

 � 

 ��

 �

�
  �*� Identifies which part of the FileDescriptorProto was defined at this
 location.

 Each element is a field number or an index.  They form a path from
 the root FileDescriptorProto to the place where the definition.  For
 example, this path:
   [ 4, 3, 2, 7, 1 ]
 refers to:
   file.message_type(3)  // 4, 3
       .field(7)         // 2, 7
       .name()           // 1
 This is because FileDescriptorProto.message_type has field number 4:
   repeated DescriptorProto message_type = 4;
 and DescriptorProto.field has field number 2:
   repeated FieldDescriptorProto field = 2;
 and FieldDescriptorProto.name has field number 1:
   optional string name = 1;

 Thus, the above path gives the location of a field name.  If we removed
 the last element:
   [ 4, 3, 2, 7 ]
 this path refers to the whole field declaration (from the beginning
 of the label to the terminating semicolon).


  �

  �

  �

  �

  �)


  � �(

  � �#

  �  �#

  �  �#

  � �$(
�
 �*� Always has exactly three or four elements: start line, start column,
 end line (optional, otherwise assumed same as start line), end column.
 These are packed into a single field for efficiency.  Note that line
 and column numbers are zero-based -- typically you will want to add
 1 to each before displaying to a user.


 �

 �

 �

 �

 �)


 � �(

 � �#

 �  �#

 �  �#

 � �$(
�
 �)� If this SourceCodeInfo represents a complete declaration, these are any
 comments appearing before and after the declaration which appear to be
 attached to the declaration.

 A series of line comments appearing on consecutive lines, with no other
 tokens appearing on those lines, will be treated as a single comment.

 leading_detached_comments will keep paragraphs of comments that appear
 before (but not connected to) the current element. Each paragraph,
 separated by empty lines, will be one comment element in the repeated
 field.

 Only the comment content is provided; comment markers (e.g. //) are
 stripped out.  For block comments, leading whitespace and an asterisk
 will be stripped from the beginning of each line other than the first.
 Newlines are included in the output.

 Examples:

   optional int32 foo = 1;  // Comment attached to foo.
   // Comment attached to bar.
   optional int32 bar = 2;

   optional string baz = 3;
   // Comment attached to baz.
   // Another line attached to baz.

   // Comment attached to qux.
   //
   // Another line attached to qux.
   optional double qux = 4;

   // Detached comment for corge. This is not leading or trailing comments
   // to qux or corge because there are blank lines separating it from
   // both.

   // Detached comment for corge paragraph 2.

   optional string corge = 5;
   /* Block comment attached
    * to corge.  Leading asterisks
    * will be removed. */
   /* Block comment attached to
    * grault. */
   optional int32 grault = 6;

   // ignored detached comments.


 �

 �

 �$

 �'(

 �*

 �

 �

 �%

 �()

 �2

 �

 �

 �-

 �01
�
� �� Describes the relationship between generated code and its original source
 file. A GeneratedCodeInfo message is associated with only one generated
 source file, but may contain references to different source .proto files.


�
x
 �%j An Annotation connects some span of text in generated code to an element
 of its generating .proto file.


 �


 �

 � 

 �#$

 ��

 �

�
  �* Identifies the element in the original source .proto file. This field
 is formatted the same as SourceCodeInfo.Location.path.


  �

  �

  �

  �

  �)


  � �(

  � �#

  �  �#

  �  �#

  � �$(
O
 �$? Identifies the filesystem path to the original source .proto.


 �

 �

 �

 �"#
w
 �g Identifies the starting offset in bytes in the generated code
 that relates to the identified object.


 �

 �

 �

 �
�
 �� Identifies the ending offset in bytes in the generated code that
 relates to the identified offset. The end offset should be one past
 the last relevant byte (so the length of the text = end - begin).


 �

 �

 �

 �
�
google/api/annotations.proto
google.apigoogle/api/http.proto google/protobuf/descriptor.proto:K
http.google.protobuf.MethodOptions�ʼ" (2.google.api.HttpRuleRhttpBn
com.google.apiBAnnotationsProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�
 
�
 2� Copyright (c) 2015, Google Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.



	
 
	
)

 X

�  X

� 

�  

�  

� W

 "

� "

�

� 

� 

�!

 1

� 1

�

� 

� 

�0

 '

� '

�

� 

� 

�&

 "

� "

�

� 

� 

�!
	
 

  See `HttpRule`.



 $

 &


 



 


 bproto3
��
z/qrl.protoqrlgoogle/api/annotations.proto"
Empty"
GetNodeStateReq"5
GetNodeStateResp!
info (2.qrl.NodeInfoRinfo"
GetKnownPeersReq"k
GetKnownPeersResp*
	node_info (2.qrl.NodeInfoRnodeInfo*
known_peers (2	.qrl.PeerR
knownPeers"
GetPeersStatReq"@
GetPeersStatResp,

peers_stat (2.qrl.PeerStatR	peersStat"
GetChainStatsReq"z
GetChainStatsResp

state_size (R	stateSize"
state_size_mb (	RstateSizeMb"
state_size_gb (	RstateSizeGb"<
GetStatsReq-
include_timeseries (RincludeTimeseries"�
GetStatsResp*
	node_info (2.qrl.NodeInfoRnodeInfo
epoch (Repoch%
uptime_network (RuptimeNetwork*
block_last_reward (RblockLastReward&
block_time_mean (RblockTimeMean"
block_time_sd (RblockTimeSd,
coins_total_supply (RcoinsTotalSupply#
coins_emitted (RcoinsEmitted>
block_timeseries	 (2.qrl.BlockDataPointRblockTimeseries"%
GetAddressFromPKReq
pk (Rpk"0
GetAddressFromPKResp
address (Raddress"�
BlockDataPoint
number (Rnumber

difficulty (	R
difficulty
	timestamp (R	timestamp
	time_last (RtimeLast
time_movavg (R
timeMovavg

hash_power (R	hashPower
header_hash (R
headerHash(
header_hash_prev (RheaderHashPrev"�
GetAddressStateReq
address (Raddress0
exclude_ots_bitfield (RexcludeOtsBitfield<
exclude_transaction_hashes (RexcludeTransactionHashes">
GetAddressStateResp'
state (2.qrl.AddressStateRstate"P
GetOptimizedAddressStateResp0
state (2.qrl.OptimizedAddressStateRstate"6
GetMultiSigAddressStateReq
address (Raddress"N
GetMultiSigAddressStateResp/
state (2.qrl.MultiSigAddressStateRstate"N

IsSlaveReq%
master_address (RmasterAddress
slave_pk (RslavePk"%
IsSlaveResp
result (Rresult"+
ParseAddressReq
address (Raddress"Y
ParseAddressResp
is_valid (RisValid*
desc (2.qrl.AddressDescriptorRdesc"$
GetObjectReq
query (Rquery"�
GetObjectResp
found (RfoundA
address_state (2.qrl.OptimizedAddressStateH RaddressState<
transaction (2.qrl.TransactionExtendedH Rtransaction;
block_extended (2.qrl.BlockExtendedH RblockExtendedB
result"�
GetLatestDataReq4
filter (2.qrl.GetLatestDataReq.FilterRfilter
offset (Roffset
quantity (Rquantity"S
Filter
ALL 
BLOCKHEADERS
TRANSACTIONS
TRANSACTIONS_UNCONFIRMED"�
GetLatestDataResp<
blockheaders (2.qrl.BlockHeaderExtendedRblockheaders<
transactions (2.qrl.TransactionExtendedRtransactionsS
transactions_unconfirmed (2.qrl.TransactionExtendedRtransactionsUnconfirmed"�
TransferCoinsReq
master_addr (R
masterAddr!
addresses_to (RaddressesTo
amounts (Ramounts!
message_data (RmessageData
fee (Rfee
xmss_pk (RxmssPk"q
TransferCoinsResp\
extended_transaction_unsigned (2.qrl.TransactionExtendedRextendedTransactionUnsigned"U
PushTransactionReq?
transaction_signed (2.qrl.TransactionRtransactionSigned"�
PushTransactionRespD

error_code (2%.qrl.PushTransactionResp.ResponseCodeR	errorCode+
error_description (	RerrorDescription
tx_hash (RtxHash"L
ResponseCode
UNKNOWN 	
ERROR
VALIDATION_FAILED
	SUBMITTED"�
MultiSigCreateTxnReq
master_addr (R
masterAddr 
signatories (Rsignatories
weights (Rweights
	threshold (R	threshold
fee (Rfee
xmss_pk (RxmssPk"�
MultiSigSpendTxnReq
master_addr (R
masterAddr*
multi_sig_address (RmultiSigAddress
addrs_to (RaddrsTo
amounts (Ramounts.
expiry_block_number (RexpiryBlockNumber
fee (Rfee
xmss_pk (RxmssPk"�
MultiSigVoteTxnReq
master_addr (R
masterAddr

shared_key (R	sharedKey
unvote (Runvote
fee (Rfee
xmss_pk (RxmssPk"�
MessageTxnReq
master_addr (R
masterAddr
message (Rmessage
addr_to (RaddrTo
fee (Rfee
xmss_pk (RxmssPk"�
TokenTxnReq
master_addr (R
masterAddr
symbol (Rsymbol
name (Rname
owner (Rowner
decimals (Rdecimals=
initial_balances (2.qrl.AddressAmountRinitialBalances
fee (Rfee
xmss_pk (RxmssPk"�
TransferTokenTxnReq
master_addr (R
masterAddr!
addresses_to (RaddressesTo!
token_txhash (RtokenTxhash
amounts (Ramounts
fee (Rfee
xmss_pk (RxmssPk"�
SlaveTxnReq
master_addr (R
masterAddr
	slave_pks (RslavePks!
access_types (RaccessTypes
fee (Rfee
xmss_pk (RxmssPk"�
LatticeTxnReq
master_addr (R
masterAddr
pk1 (Rpk1
pk2 (Rpk2
pk3 (Rpk3
fee (Rfee
xmss_pk (RxmssPk"f
MiniTransaction)
transaction_hash (	RtransactionHash
out (Rout
amount (Ramount",
GetTransactionReq
tx_hash (RtxHash"�
GetTransactionResp 
tx (2.qrl.TransactionRtx$
confirmations (Rconfirmations!
block_number (RblockNumber*
block_header_hash (RblockHeaderHash
	timestamp (R	timestamp
	addr_from (RaddrFrom"�
GetMiniTransactionsByAddressReq
address (Raddress"
item_per_page (RitemPerPage
page_number (R
pageNumber"
 GetMiniTransactionsByAddressRespA
mini_transactions (2.qrl.MiniTransactionRminiTransactions
balance (Rbalance"|
GetTransactionsByAddressReq
address (Raddress"
item_per_page (RitemPerPage
page_number (R
pageNumber"h
GetTransactionsByAddressRespH
transactions_detail (2.qrl.GetTransactionRespRtransactionsDetail"�
GetMultiSigSpendTxsByAddressReq
address (Raddress"
item_per_page (RitemPerPage
page_number (R
pageNumberP
filter_type (2/.qrl.GetMultiSigSpendTxsByAddressReq.FilterTypeR
filterType"�

FilterType
NONE 
EXECUTED_ONLY
NON_EXECUTED
EXPIRED
NON_EXPIRED
NON_EXECUTED_EXPIRED
NON_EXECUTED_NON_EXPIRED"l
 GetMultiSigSpendTxsByAddressRespH
transactions_detail (2.qrl.GetTransactionRespRtransactionsDetail"G
GetVoteStatsReq4
multi_sig_spend_tx_hash (RmultiSigSpendTxHash"A
GetVoteStatsResp-

vote_stats (2.qrl.VoteStatsR	voteStats"i
GetInboxMessagesByAddressRespH
transactions_detail (2.qrl.GetTransactionRespRtransactionsDetail"�
InboxMessage
	addr_from (RaddrFrom
	timestamp (R	timestamp
message (Rmessage
tx_hash (RtxHash!
block_number (RblockNumber"v
TokenDetail!
token_txhash (RtokenTxhash
name (Rname
symbol (Rsymbol
balance (Rbalance"O
GetTokensByAddressResp5
tokens_detail (2.qrl.TokenDetailRtokensDetail"S
SlaveDetail#
slave_address (RslaveAddress
access_type (R
accessType"O
GetSlavesByAddressResp5
slaves_detail (2.qrl.SlaveDetailRslavesDetail"a
LatticePKsDetail
pk1 (Rpk1
pk2 (Rpk2
pk3 (Rpk3
tx_hash (RtxHash"a
GetLatticePKsByAddressRespC
lattice_pks_detail (2.qrl.LatticePKsDetailRlatticePksDetail"D
MultiSigDetail
address (Raddress
balance (Rbalance"b
!GetMultiSigAddressesByAddressResp=
multi_sig_detail (2.qrl.MultiSigDetailRmultiSigDetail")
GetBalanceReq
address (Raddress"*
GetBalanceResp
balance (Rbalance"2
GetTotalBalanceReq
	addresses (R	addresses"/
GetTotalBalanceResp
balance (Rbalance"�
	GetOTSReq
address (Raddress
	page_from (RpageFrom

page_count (R	pageCount1
unused_ots_index_from (RunusedOtsIndexFrom"W
OTSBitfieldByPage!
ots_bitfield (RotsBitfield
page_number (R
pageNumber"�

GetOTSRespG
ots_bitfield_by_page (2.qrl.OTSBitfieldByPageRotsBitfieldByPage1
next_unused_ots_index (RnextUnusedOtsIndex3
unused_ots_index_found (RunusedOtsIndexFound"
GetHeightReq"'
GetHeightResp
height (Rheight".
GetBlockReq
header_hash (R
headerHash"0
GetBlockResp 
block (2
.qrl.BlockRblock"8
GetBlockByNumberReq!
block_number (RblockNumber"8
GetBlockByNumberResp 
block (2
.qrl.BlockRblock"
GetLocalAddressesReq"5
GetLocalAddressesResp
	addresses (R	addresses"�
NodeInfo
version (	Rversion)
state (2.qrl.NodeInfo.StateRstate'
num_connections (RnumConnections&
num_known_peers (RnumKnownPeers
uptime (Ruptime!
block_height (RblockHeight&
block_last_hash (RblockLastHash

network_id (	R	networkId"G
State
UNKNOWN 
UNSYNCED
SYNCING

SYNCED

FORKED"�
AddressDescriptor#
hash_function (	RhashFunction)
signature_scheme (	RsignatureScheme
tree_height (R
treeHeight

signatures (R
signatures%
address_format (	RaddressFormat".
StoredPeers
peers (2	.qrl.PeerRpeers"
Peer
ip (	Rip"�
AddressState
address (Raddress
balance (Rbalance
nonce (Rnonce!
ots_bitfield (RotsBitfield-
transaction_hashes (RtransactionHashes5
tokens (2.qrl.AddressState.TokensEntryRtokens5
latticePK_list (2.qrl.LatticePKRlatticePKList\
slave_pks_access_type (2).qrl.AddressState.SlavePksAccessTypeEntryRslavePksAccessType
ots_counter	 (R
otsCounter9
TokensEntry
key (	Rkey
value (Rvalue:8E
SlavePksAccessTypeEntry
key (	Rkey
value (Rvalue:8"�
OptimizedAddressState
address (Raddress
balance (Rbalance
nonce (Rnonce3
ots_bitfield_used_page (RotsBitfieldUsedPage+
used_ots_key_count (RusedOtsKeyCount4
transaction_hash_count (RtransactionHashCount!
tokens_count (RtokensCount!
slaves_count (RslavesCount(
lattice_pk_count	 (RlatticePkCount5
multi_sig_address_count
 (RmultiSigAddressCount1
multi_sig_spend_count (RmultiSigSpendCount.
inbox_message_count (RinboxMessageCountK
#foundation_multi_sig_spend_txn_hash (RfoundationMultiSigSpendTxnHashI
"foundation_multi_sig_vote_txn_hash (RfoundationMultiSigVoteTxnHash
unvotes (Runvotes@
proposal_vote_stats (2.qrl.TransactionRproposalVoteStats"�
MultiSigAddressState
address (Raddress(
creation_tx_hash (RcreationTxHash
nonce (Rnonce
balance (Rbalance 
signatories (Rsignatories
weights (Rweights
	threshold (R	threshold4
transaction_hash_count (RtransactionHashCount1
multi_sig_spend_count	 (RmultiSigSpendCount5
multi_sig_address_count
 (RmultiSigAddressCountK
#foundation_multi_sig_spend_txn_hash (RfoundationMultiSigSpendTxnHashI
"foundation_multi_sig_vote_txn_hash (RfoundationMultiSigVoteTxnHash
unvotes (Runvotes@
proposal_vote_stats (2.qrl.TransactionRproposalVoteStats"/
MultiSigAddressesList
hashes (Rhashes""
DataList
values (Rvalues"(
Bitfield
	bitfields (R	bitfields"-
TransactionHashList
hashes (Rhashes"I
	LatticePK
kyber_pk (RkyberPk!
dilithium_pk (RdilithiumPk"A
AddressAmount
address (Raddress
amount (Ramount"�
BlockHeader
hash_header (R
hashHeader!
block_number (RblockNumber+
timestamp_seconds (RtimestampSeconds(
hash_header_prev (RhashHeaderPrev!
reward_block (RrewardBlock

reward_fee (R	rewardFee
merkle_root (R
merkleRoot!
mining_nonce (RminingNonce
extra_nonce	 (R
extraNonce"�
BlockHeaderExtended(
header (2.qrl.BlockHeaderRheaderB
transaction_count (2.qrl.TransactionCountRtransactionCount"�
TransactionCount6
count (2 .qrl.TransactionCount.CountEntryRcount8

CountEntry
key (Rkey
value (Rvalue:8"�
TransactionExtended(
header (2.qrl.BlockHeaderRheader 
tx (2.qrl.TransactionRtx
	addr_from (RaddrFrom
size (Rsize+
timestamp_seconds (RtimestampSeconds"�
BlockExtended(
header (2.qrl.BlockHeaderRheaderM
extended_transactions (2.qrl.TransactionExtendedRextendedTransactions<
genesis_balance (2.qrl.GenesisBalanceRgenesisBalance
size (Rsize"�
Block(
header (2.qrl.BlockHeaderRheader4
transactions (2.qrl.TransactionRtransactions<
genesis_balance (2.qrl.GenesisBalanceRgenesisBalance"D
GenesisBalance
address (Raddress
balance (Rbalance"W
BlockMetaDataListB
block_number_hashes (2.qrl.BlockMetaDataRblockNumberHashes"�
Transaction
master_addr (R
masterAddr
fee (Rfee

public_key (R	publicKey
	signature (R	signature
nonce (Rnonce)
transaction_hash (RtransactionHash7
transfer (2.qrl.Transaction.TransferH Rtransfer7
coinbase (2.qrl.Transaction.CoinBaseH RcoinbaseA
	latticePK	 (2!.qrl.Transaction.LatticePublicKeyH R	latticePK4
message
 (2.qrl.Transaction.MessageH Rmessage.
token (2.qrl.Transaction.TokenH RtokenG
transfer_token (2.qrl.Transaction.TransferTokenH RtransferToken.
slave (2.qrl.Transaction.SlaveH RslaveK
multi_sig_create (2.qrl.Transaction.MultiSigCreateH RmultiSigCreateH
multi_sig_spend (2.qrl.Transaction.MultiSigSpendH RmultiSigSpendE
multi_sig_vote (2.qrl.Transaction.MultiSigVoteH RmultiSigVoteJ
proposal_create (2.qrl.Transaction.ProposalCreateH RproposalCreateD
proposal_vote (2.qrl.Transaction.ProposalVoteH RproposalVoteb
Transfer
addrs_to (RaddrsTo
amounts (Ramounts!
message_data (RmessageData;
CoinBase
addr_to (RaddrTo
amount (RamountH
LatticePublicKey
pk1 (Rpk1
pk2 (Rpk2
pk3 (Rpk3E
Message!
message_hash (RmessageHash
addr_to (RaddrTo�
Token
symbol (Rsymbol
name (Rname
owner (Rowner
decimals (Rdecimals=
initial_balances (2.qrl.AddressAmountRinitialBalancesg
TransferToken!
token_txhash (RtokenTxhash
addrs_to (RaddrsTo
amounts (RamountsG
Slave
	slave_pks (RslavePks!
access_types (RaccessTypesj
MultiSigCreate 
signatories (Rsignatories
weights (Rweights
	threshold (R	threshold�
MultiSigSpend*
multi_sig_address (RmultiSigAddress
addrs_to (RaddrsTo
amounts (Ramounts.
expiry_block_number (RexpiryBlockNumberg
MultiSigVote

shared_key (R	sharedKey
unvote (Runvote 
prev_tx_hash (R
prevTxHash�
ProposalCreate.
expiry_block_number (RexpiryBlockNumber 
description (	Rdescription7
qip (2#.qrl.Transaction.ProposalCreate.QIPH Rqip@
config (2&.qrl.Transaction.ProposalCreate.ConfigH Rconfig=
other (2%.qrl.Transaction.ProposalCreate.OtherH Rother 
QIP
qip_link (	RqipLink�
Config)
changes_bitfield (RchangesBitfield
reorg_limit (R
reorgLimit&
max_coin_supply (RmaxCoinSupplyM
$complete_emission_time_span_in_years (RcompleteEmissionTimeSpanInYears.
mining_nonce_offset (RminingNonceOffset,
extra_nonce_offset (RextraNonceOffset8
mining_blob_size_in_bytes (RminingBlobSizeInBytes5
block_timing_in_seconds (RblockTimingInSeconds7
number_of_blocks_analyze	 (RnumberOfBlocksAnalyze2
block_size_multiplier
 (RblockSizeMultiplier?
block_min_size_limit_in_bytes (RblockMinSizeLimitInBytesC
transaction_multi_output_limit (RtransactionMultiOutputLimit,
message_max_length (RmessageMaxLength5
token_symbol_max_length (RtokenSymbolMaxLength1
token_name_max_length (RtokenNameMaxLength3
lattice_pk1_max_length (RlatticePk1MaxLength3
lattice_pk2_max_length (RlatticePk2MaxLength3
lattice_pk3_max_length (RlatticePk3MaxLengthg
1foundation_multi_sig_address_threshold_percentage (R,foundationMultiSigAddressThresholdPercentage4
proposal_threshold_per (RproposalThresholdPer8
proposal_default_options (	RproposalDefaultOptions4
description_max_length (RdescriptionMaxLength,
options_max_number (RoptionsMaxNumber3
option_max_text_length (RoptionMaxTextLengthG
 proposal_config_activation_delay (RproposalConfigActivationDelay#
N_measurement (RNMeasurement
kp (Rkp!
Other
options (	RoptionsB
proposalTypeE
ProposalVote

shared_key (R	sharedKey
option (RoptionB
transactionType"�
	VoteStats*
multi_sig_address (RmultiSigAddress

shared_key (R	sharedKey 
signatories (Rsignatories
	tx_hashes (RtxHashes
unvotes (Runvotes.
expiry_block_number (RexpiryBlockNumber!
total_weight (RtotalWeight
executed (Rexecuted"�
ProposalVoteStats
	addr_from (RaddrFrom

shared_key (R	sharedKey#
proposal_type (	RproposalType(
weight_by_option (RweightByOption.
expiry_block_number (RexpiryBlockNumber
executed (Rexecuted-
number_of_tx_hashes (RnumberOfTxHashes"?
ProposalRecord-
number_of_tx_hashes (RnumberOfTxHashes".
	TokenList!
token_txhash (RtokenTxhash"u
TokenBalance
balance (Rbalance
decimals (Rdecimals
tx_hash (RtxHash
delete (Rdelete"a
SlaveMetadata
access_type (R
accessType
tx_hash (RtxHash
delete (Rdelete"^
LatticePKMetadata
enabled (Renabled
tx_hash (RtxHash
delete (Rdelete"k
TokenMetadata!
token_txhash (RtokenTxhash7
transfer_token_tx_hashes (RtransferTokenTxHashes"�
EncryptedEphemeralMessage
msg_id (RmsgId
ttl (Rttl
ttr (Rttr@
channel (2&.qrl.EncryptedEphemeralMessage.ChannelRchannel
nonce (Rnonce
payload (Rpayload5
Channel*
enc_aes256_symkey (RencAes256Symkey"+
AddressList
	addresses (R	addresses"�
BlockHeightData!
block_number (RblockNumber)
block_headerhash (RblockHeaderhash3
cumulative_difficulty (RcumulativeDifficulty"�
BlockMetaData)
block_difficulty (RblockDifficulty3
cumulative_difficulty (RcumulativeDifficulty-
child_headerhashes (RchildHeaderhashes.
last_N_headerhashes (RlastNHeaderhashes"]
BlockNumberMapping

headerhash (R
headerhash'
prev_headerhash (RprevHeaderhash"v
PeerStat
peer_ip (RpeerIp
port (Rport=
node_chain_state (2.qrl.NodeChainStateRnodeChainState"�
NodeChainState!
block_number (RblockNumber
header_hash (R
headerHash3
cumulative_difficulty (RcumulativeDifficulty
version (	Rversion
	timestamp (R	timestamp"W
NodeHeaderHash!
block_number (RblockNumber"
headerhashes (Rheaderhashes"=
P2PAcknowledgement'
bytes_processed (RbytesProcessed"�
PeerInfo
peer_ip (RpeerIp
port (Rport)
banned_timestamp (RbannedTimestamp 
credibility (Rcredibility<
last_connections_timestamp (RlastConnectionsTimestamp"<
Peers3
peer_info_list (2.qrl.PeerInfoRpeerInfoList"�
	DevConfig$
prev_state_key (RprevStateKey*
current_state_key (RcurrentStateKey4
activation_header_hash (RactivationHeaderHash6
activation_block_number (RactivationBlockNumber*
chain (2.qrl.DevConfig.ChainRchain*
block (2.qrl.DevConfig.BlockRblock<
transaction (2.qrl.DevConfig.TransactionRtransaction$
pow (2.qrl.DevConfig.POWRpow�
Chain
reorg_limit (R
reorgLimit&
max_coin_supply (RmaxCoinSupplyM
$complete_emission_time_span_in_years (RcompleteEmissionTimeSpanInYears�
Block.
mining_nonce_offset (RminingNonceOffset,
extra_nonce_offset (RextraNonceOffset8
mining_blob_size_in_bytes (RminingBlobSizeInBytes5
block_timing_in_seconds (RblockTimingInSeconds\
block_size_controller (2(.qrl.DevConfig.Block.BlockSizeControllerRblockSizeController�
BlockSizeController7
number_of_blocks_analyze (RnumberOfBlocksAnalyze'
size_multiplier (RsizeMultiplier?
block_min_size_limit_in_bytes (RblockMinSizeLimitInBytes�	
Transaction,
multi_output_limit (RmultiOutputLimit<
message (2".qrl.DevConfig.Transaction.MessageRmessage6
slave (2 .qrl.DevConfig.Transaction.SlaveRslave6
token (2 .qrl.DevConfig.Transaction.TokenRtoken<
lattice (2".qrl.DevConfig.Transaction.LatticeRlattice_
foundation_multi_sig (2-.qrl.DevConfig.Transaction.FoundationMultiSigRfoundationMultiSig?
proposal (2#.qrl.DevConfig.Transaction.ProposalRproposal(
Message

max_length (R	maxLength6
Slave-
slave_pk_max_length (RslavePkMaxLength[
Token*
symbol_max_length (RsymbolMaxLength&
name_max_length (RnameMaxLength{
Lattice$
pk1_max_length (Rpk1MaxLength$
pk2_max_length (Rpk2MaxLength$
pk3_max_length (Rpk3MaxLengthG
FoundationMultiSig1
threshold_percentage (RthresholdPercentage�
Proposal#
threshold_per (RthresholdPer'
default_options (	RdefaultOptions4
description_max_length (RdescriptionMaxLength,
options_max_number (RoptionsMaxNumber3
option_max_text_length (RoptionMaxTextLengthG
 proposal_config_activation_delay (RproposalConfigActivationDelay:
POW#
N_measurement (RNMeasurement
kp (Rkp2�
	PublicAPIP
GetNodeState.qrl.GetNodeStateReq.qrl.GetNodeStateResp"���/node-stateT
GetKnownPeers.qrl.GetKnownPeersReq.qrl.GetKnownPeersResp"���/known-peersP
GetPeersStat.qrl.GetPeersStatReq.qrl.GetPeersStatResp"���/peers-stat?
GetStats.qrl.GetStatsReq.qrl.GetStatsResp"���/stats\
GetAddressState.qrl.GetAddressStateReq.qrl.GetAddressStateResp"���/address-statex
GetOptimizedAddressState.qrl.GetAddressStateReq!.qrl.GetOptimizedAddressStateResp" ���/optimized-address-state~
GetMultiSigAddressState.qrl.GetMultiSigAddressStateReq .qrl.GetMultiSigAddressStateResp" ���/multi-sig-address-state?
IsSlave.qrl.IsSlaveReq.qrl.IsSlaveResp"���	/is-slaveC
	GetObject.qrl.GetObjectReq.qrl.GetObjectResp"���	/objectT
GetLatestData.qrl.GetLatestDataReq.qrl.GetLatestDataResp"���/latest-data_
PushTransaction.qrl.PushTransactionReq.qrl.PushTransactionResp"���"/push-transactionW
TransferCoins.qrl.TransferCoinsReq.qrl.TransferCoinsResp"���"/transfer-coinsS
ParseAddress.qrl.ParseAddressReq.qrl.ParseAddressResp"���/parse-addressT
GetChainStats.qrl.GetChainStatsReq.qrl.GetChainStatsResp"���/chain-statsa
GetAddressFromPK.qrl.GetAddressFromPKReq.qrl.GetAddressFromPKResp"���/address-from-pkh
GetMultiSigCreateTxn.qrl.MultiSigCreateTxnReq.qrl.TransferCoinsResp"���"/multi-sig-create-txne
GetMultiSigSpendTxn.qrl.MultiSigSpendTxnReq.qrl.TransferCoinsResp"���"/multi-sig-spend-txnb
GetMultiSigVoteTxn.qrl.MultiSigVoteTxnReq.qrl.TransferCoinsResp"���"/multi-sig-vote-txnQ
GetMessageTxn.qrl.MessageTxnReq.qrl.TransferCoinsResp"���"/message-txnK
GetTokenTxn.qrl.TokenTxnReq.qrl.TransferCoinsResp"���"
/token-txnd
GetTransferTokenTxn.qrl.TransferTokenTxnReq.qrl.TransferCoinsResp"���"/transfer-token-txnK
GetSlaveTxn.qrl.SlaveTxnReq.qrl.TransferCoinsResp"���"
/slave-txnQ
GetLatticeTxn.qrl.LatticeTxnReq.qrl.TransferCoinsResp"���"/lattice-txnW
GetTransaction.qrl.GetTransactionReq.qrl.GetTransactionResp"���/transaction�
GetMiniTransactionsByAddress$.qrl.GetMiniTransactionsByAddressReq%.qrl.GetMiniTransactionsByAddressResp"$���/mini-transaction-by-address�
GetTransactionsByAddress .qrl.GetTransactionsByAddressReq!.qrl.GetTransactionsByAddressResp" ���/transactions-by-addresso
GetTokensByAddress .qrl.GetTransactionsByAddressReq.qrl.GetTokensByAddressResp"���/tokens-by-addresso
GetSlavesByAddress .qrl.GetTransactionsByAddressReq.qrl.GetSlavesByAddressResp"���/slaves-by-address|
GetLatticePKsByAddress .qrl.GetTransactionsByAddressReq.qrl.GetLatticePKsByAddressResp"���/lattice-pks-by-address�
GetMultiSigAddressesByAddress .qrl.GetTransactionsByAddressReq&.qrl.GetMultiSigAddressesByAddressResp"'���!/multi-sig-addresses-by-address�
GetMultiSigSpendTxsByAddress$.qrl.GetMultiSigSpendTxsByAddressReq%.qrl.GetMultiSigSpendTxsByAddressResp"'���!/multi-sig-spend-txs-by-addressP
GetVoteStats.qrl.GetVoteStatsReq.qrl.GetVoteStatsResp"���/vote-stats�
GetInboxMessagesByAddress .qrl.GetTransactionsByAddressReq".qrl.GetInboxMessagesByAddressResp""���/inbox-messages-by-addressG

GetBalance.qrl.GetBalanceReq.qrl.GetBalanceResp"���
/balance\
GetTotalBalance.qrl.GetTotalBalanceReq.qrl.GetTotalBalanceResp"���/total-balance7
GetOTS.qrl.GetOTSReq.qrl.GetOTSResp"���/otsC
	GetHeight.qrl.GetHeightReq.qrl.GetHeightResp"���	/height?
GetBlock.qrl.GetBlockReq.qrl.GetBlockResp"���/blocka
GetBlockByNumber.qrl.GetBlockByNumberReq.qrl.GetBlockByNumberResp"���/block-by-number2

AdminAPIJ��
 �	
�
 2� Distributed under the MIT software license, see the accompanying
 file LICENSE or http://www.opensource.org/licenses/mit-license.php.

	
 %


�
  �H This service describes the Public API used by clients (wallet/cli/etc)
2�//////////////////////////
//////////////////////////
//////////////////////////
////     API       ///////
//////////////////////////
//////////////////////////
//////////////////////////



 

  

  

  %

  0@

  

  � 

	  � 


  �  

  �  

	  � !

 

 

 '

 2C

 

 � 

	 � 


 �  

 �  

	 � !

 #

 

 %

 0@

  "

 �  "

	 �  


 �   

 �   

	 �  !"

 %)

 %

 %

 %(4

 &(

 � &(

	 � &


 �  &

 �  &

	 � &!(

 +/

 +

 ++

 +6I

 ,.

 � ,.

	 � ,


 �  ,

 �  ,

	 � ,!.

 15

 1 

 1"4

 1?[

 24

 � 24

	 � 2


 �  2

 �  2

	 � 2!4

 7;

 7

 7!;

 7Fa

 8:

 � 8:

	 � 8


 �  8

 �  8

	 � 8!:

 =A

 =

 =

 =&1

 >@

 � >@

	 � >


 �  >

 �  >

	 � >!@

 CG

 C

 C

 C)6

 DF

 � DF

	 � D


 �  D

 �  D

	 � D!F

 	IM

 	I

 	I&

 	I1B

 	JL

 	� JL

	 	� J


 	�  J

 	�  J

	 	� J!L

 
OS

 
O

 
O+

 
O6I

 
PR

 
� PR

	 
� P


 
�  P

 
�  P

	 
� P!R

 UY

 U

 U'

 U2C

 VX

 � VX

	 � V


 �  V

 �  V

	 � V!X

 [_

 [

 [%

 [0@

 \^

 � \^

	 � \


 �  \

 �  \

	 � \!^

 ae

 a

 a'

 a2C

 bd

 � bd

	 � b


 �  b

 �  b

	 � b!d

 gk

 g

 g-

 g8L

 hj

 � hj

	 � h


 �  h

 �  h

	 � h!j

 mq

 m

 m2

 m=N

 np

 � np

	 � n


 �  n

 �  n

	 � n!p

 sw

 s

 s0

 s;L

 tv

 � tv

	 � t


 �  t

 �  t

	 � t!v

 y}

 y

 y.

 y9J

 z|

 � z|

	 � z


 �  z

 �  z

	 � z!|

 �

 

 $

 /@

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 � 

 �+<

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 �0

 �;L

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 � 

 �+<

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 �$

 �/@

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 �(

 �3E

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �$

 �%D

 �Oo

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 � 

 �!<

 �Gc

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 �6

 �AW

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 �6

 �AW

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 �:

 �E_

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �%

 �&A

 �Lm

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �$

 �%D

 �Oo

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

 ��

 �

 �$

 �/?

 ��

 � ��

	 � �


 �  �

 �  �

	 � �!�

  ��

  �!

  �"=

  �He

  ��

  � ��

	  � �


  �  �

  �  �

	  � �!�

 !��

 !�

 !� 

 !�+9

 !��

 !� ��

	 !� �


 !�  �

 !�  �

	 !� �!�

 "��

 "�

 "�*

 "�5H

 "��

 "� ��

	 "� �


 "�  �

 "�  �

	 "� �!�

 #��

 #�

 #�

 #�#-

 #��

 #� ��

	 #� �


 #�  �

 #�  �

	 #� �!�

 $��

 $�

 $�

 $�)6

 $��

 $� ��

	 $� �


 $�  �

 $�  �

	 $� �!�

 %��

 %�

 %�

 %�'3

 %��

 %� ��

	 %� �


 %�  �

 %�  �

	 %� �!�

 &��

 &�

 &�,

 &�7K

 &��

 &� ��

	 &� �


 &�  �

 &�  �

	 &� �!�
G
� �9 This is a place holder for testing/instrumentation APIs


�
�
 � *
 Empty message definition
2�//////////////////////////
//////////////////////////
//////////////////////////
    Request/Response    //
//////////////////////////
//////////////////////////
//////////////////////////


 �
4
� (*
 Represents a query to get node state


�
B
� �4*
 Represents the reply message to node state query


�

 �

 ��

 �

 �

 �
5
� )*
 Represents a query to get known peers


�
C
� �5*
 Represents the reply message to known peers query


�
A
 �"3 NodeInfo object containing node state information


 ��

 �

 �

 �
O
�""A List of Peer objects containing peer nodes detailed information


�

�

�

� !
>
� 2*
 Represents a query to get connected peers stat


�
B
� �4*
 Represents the reply message to peers stat query


�
R
 �%"D PeerState object contains peer_ip, port and peer state information


 �

 �

 � 

 �#$
7
� 2+*
 Represents the query for get chain size


�
B
� �24*
 Represents the reply message for get chain stats


�
0
 �"" whole state folder size in bytes


 ��

 �


 �

 �

�" megabytes


��

�


�

�

�" gigabytes


��

�


�

�
A
	� �3*
 Represents a query to get statistics about node


	�
X
	 � "J Boolean to define if block timeseries should be included in reply or not


	 ��

	 �

	 �	

	 �
K

� �=*
 Represents the reply message to get statistics about node



�
A

 �"3 NodeInfo object containing node state information



 ��


 �


 �


 �


�" Current epoch



��


�



�


�
+

�" Indicates uptime in seconds



��


�



�


�


�!" Block reward



��


�



�


� 
!

�" Blocktime average



��!


�



�


�
,

�" Blocktime standrad deviation



��


�



�


�
"

�"" Total coins supply



��


�



�


� !
#

�" Total coins emitted



��"


�



�


�


�1


�


�


�,


�/0

� �

�

 �

 ��

 �	

 �


 �

� �

�

 �

 ��

 �	

 �


 �
3
� �%*
 BlockDataPoint message definition


�

 �" Block number


 ��

 �


 �

 �
 
�" Block difficulty


��

�


�

�

�" Block timestamp


��

�


�

�

�

��

�


�

�

�

��

�


�

�

�" Hash power


��

�	

�


�
!
�" Block header hash


��

�	

�


�
,
�" Previous block's header hash


��

�	

�


�

� �

�

 �

 ��

 �	

 �


 �

�"

��

�

�	

� !

�(

��"

�

�	#

�&'

� �

�

 �

 ��

 �

 �

 �

� �

�$

 �$

 ��&

 �

 �

 �"#

� �

�"

 �

 ��$

 �	

 �


 �

� �

�#

 �#

 ��%

 �

 �

 �!"

� �

�

 �

 ��

 �	

 �


 �

�

��

�	

�


�

� �

�

 �

 ��

 �

 �	

 �

� �

�

 �

 ��

 �	

 �


 �

� �

�

 �

 ��

 �

 �	

 �

�

��

�

�

�


� -

�

 �(

 �

 �

 �#

 �&'

� �

�

 �

 ��

 �

 �	

 �

 ��

 �


�0

�

�+

�./

�,

�

�'

�*+

�)

�

�$

�'(

� �

�

 ��

 �	

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �%

 � 

 �#$

 �

 ��

 �


 �

 �
H
�": Offset in the result list (works backwards in this case)


��

�


�

�
9
�"+ Number of items to retrive. Capped at 100


��

�


�

�

� �

�

 �2

 �

 � 

 �!-

 �01

�2

�

� 

�!-

�01

�>

�

� 

�!9

�<=

� �

�
*
 �" Transaction source address


 ��

 �	

 �


 �
/
�$"! Transaction destination address


�

�

�

�"#
6
� "( Amount. It should be expressed in Shor


�

�

�

�
=
�"/ Message Data. Optional field to send messages


�� 

�	

�


�
3
�"% Fee. It should be expressed in Shor


��

�


�

�

�" XMSS Public key


��

�	

�


�

� �

�

 �:

 ��

 �

 �5

 �89


� I

�

 � C

 � 

 � +

 �,>

 �AB

� �

�

 ��

 �	

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 � 

 ��

 �

 �

 �

�!

�� 

�


�

� 

�

��!

�	

�


�

� �

�

 �

 ��

 �	

 �


 �

�#

�

�

�

�!"

� 

�

�

�

�

�

�� 

�


�

�

�

��

�


�

�

�

��

�	

�


�

 � �

 �

  �

  ��

  �	

  �


  �

 � 

 ��

 �	

 �


 �

 � 

 �

 �

 �

 �

 � 

 �

 �

 �

 �

 �#

 �� 

 �


 �

 �!"

 �

 ��#

 �


 �

 �

 �

 ��

 �	

 �


 �

!� �

!�

! �

! ��

! �	

! �


! �

!�

!��

!�	

!�


!�

!�

!��

!�

!�	

!�

!�

!��

!�


!�

!�

!�

!��

!�	

!�


!�

"� �

"�

" �

" ��

" �	

" �


" �

"�

"��

"�	

"�


"�

"�

"��

"�	

"�


"�

"�

"��

"�


"�

"�

"�

"��

"�	

"�


"�

#� �

#�

# �

# ��

# �	

# �


# �

#�

#��

#�	

#�


#�

#�

#��

#�	

#�


#�

#�

#��

#�	

#�


#�

#�

#��

#�


#�

#�

#�0

#�

#�

#�+

#�./

#�

#��0

#�


#�

#�

#�

#��

#�	

#�


#�

$� �

$�

$ �

$ ��

$ �	

$ �


$ �

$�$

$�

$�

$�

$�"#

$�

$��$

$�	

$�


$�

$� 

$�

$�

$�

$�

$�

$�� 

$�


$�

$�

$�

$��

$�	

$�


$�

%� �

%�

% �

% ��

% �	

% �


% �

%�!

%�

%�

%�

%� 

%�%

%�

%�

%� 

%�#$

%�

%��%

%�


%�

%�

%�

%��

%�	

%�


%�

&� �

&�

& �

& ��

& �	

& �


& �

&�

&��

&�	

&�


&�

&�

&��

&�	

&�


&�

&�

&��

&�	

&�


&�

&�

&��

&�


&�

&�

&�

&��

&�	

&�


&�

'� �

'�

' � 

' ��

' �


' �

' �

'�

'�� 

'�

'�	

'�

'�

'��

'�


'�

'�

(� �

(�

( �

( ��

( �	

( �


( �

)� �

)�

) �

) ��

) �

) �

) �

)�

)��

)�


)�

)�

)�

)��

)�


)�

)�

)� 

)��

)�	

)�


)�

)�

)�� 

)�


)�

)�

)�

)��

)�	

)�


)�

*� �

*�'

* �

* ��)

* �	

* �


* �

*�

*��

*�


*�

*�

*�

*��

*�


*�

*�

+� �

+�(

+ �3

+ �

+ �

+ �.

+ �12

+�

+��3

+�


+�

+�

,� �

,�#

, �

, ��%

, �	

, �


, �

,�

,��

,�


,�

,�

,�

,��

,�


,�

,�

-� �

-�$

- �8

- �

- �

- � 3

- �67

.� �

.�'

. ��

. �	

.  �

.  �

.  �

. �

. �

. �

. �

. �

. �

. �

. �

. �

. �

. �

. �

. �!

. �

. � 

. �%

. � 

. �#$

. �

. ��

. �	

. �


. �

.�

.��

.�


.�

.�

.�

.��

.�


.�

.�

.�

.��

.�

.�

.�

/� �

/�(

/ �8

/ �

/ �

/ � 3

/ �67

0� �

0�

0 �&

0 ��

0 �	

0 �
!

0 �$%

1� �

1�

1 �

1 ��

1 �

1 �

1 �

2� �

2�%

2 �8

2 �

2 �

2 � 3

2 �67

3� �

3�

3 �

3 ��

3 �	

3 �


3 �

3�

3��

3�


3�

3�

3�

3��

3�	

3�


3�

3�

3��

3�	

3�


3�

3�

3��

3�


3�

3�

4� �

4�

4 �

4 ��

4 �	

4 �


4 �

4�

4��

4�	

4�


4�

4�

4��

4�	

4�


4�

4�

4��

4�


4�

4�

5� �

5�

5 �+

5 �

5 �

5 �&

5 �)*

6� �

6�

6 �

6 ��

6 �	

6 �


6 �

6�

6��

6�


6�

6�

7� �

7�

7 �+

7 �

7 �

7 �&

7 �)*

8� �

8�

8 �

8 ��

8 �	

8 �


8 �

8�

8��

8�	

8�


8�

8�

8��

8�	

8�


8�

8�

8��

8�	

8�


8�

9� �

9�"

9 �5

9 �

9 �

9 �0

9 �34

:� �

:�

: �

: ��

: �	

: �


: �

:�

:��

:�


:�

:�

;� �

;�)

; �1

; �

; �

; �,

; �/0

<� �

<�

< �

< ��

< �	

< �


< �

=� �

=�

= �

= ��

= �


= �

= �

>� �

>�

> �!

> �

> �

> �

> � 

?� �

?�

? �

? ��

? �


? �

? �

@� �

@�

@ �

@ ��

@ �	

@ �


@ �

@�

@��

@�


@�

@�

@�

@��

@�


@�

@�

@�%

@��

@�


@� 

@�#$

A� �

A�

A �$

A �

A �

A �

A �"#

A�

A��$

A�


A�

A�

B� �

B�

B �8

B �

B �

B �3

B �67

B�%

B��8

B�


B� 

B�#$

B�$

B��%

B�

B�	

B�"#

C� �

C�

D� �

D�

D �

D ��

D �


D �

D �

E� �

E�

E �

E ��

E �	

E �


E �

F� �

F�

F �

F ��

F �	

F �


F �

G� �

G�

G �

G ��

G �


G �

G �

H� �

H�

H �

H ��

H �	

H �


H �
�
I�  2�//////////////////////////
//////////////////////////
//////////////////////////
//////////////////////////
//////////////////////////
//////////////////////////
//////////////////////////


I�

J� �

J�

J �!

J �

J �

J �

J � 
�
K� �2�//////////////////////////
//////////////////////////
//////////////////////////
         Content        //
//////////////////////////
//////////////////////////
//////////////////////////


K�

K ��

K �	

K  �

K  �

K  �

K �

K �

K �

K �

K �

K �

K �

K �

K �

K �

K �

K �

K �

K ��

K �


K �

K �

K�

K��

K�	

K�

K�

K�

K��

K�


K�

K�

K�

K��

K�


K�

K�
!
K�" Uptime in seconds


K��

K�


K�

K�

K�

K��

K�


K�

K�

K�

K��

K�	

K�

K�

K�

K��

K�


K�

K�
t
L� �"f 3 byte scheme, 0-3 bits = hf, 4-7 = sig scheme, 8-11 = params (inc h), 12-15 addr fmt, 16-23 params2


L�

L �

L ��

L �


L �

L �

L� 

L��

L�


L�

L�

L�

L�� 

L�


L�

L�

L�

L��

L�


L�

L�

L�

L��

L�


L�

L�

M� �

M�

M �

M �

M �

M �

M �

N� �

N�

N �

N ��

N �


N �

N �

O� �

O�

O �

O ��

O �	

O �


O �

O�

O��

O�


O�

O�
.
O�"  FIXME: Discuss. 32 or 64 bits?


O��

O�


O�

O�

O�$

O�

O�

O�

O�"#

O�*

O�

O�

O�%

O�()

O�#

O��*

O�

O�

O�!"

O�*

O�

O�

O�%

O�()

O�2

O��*

O�

O�-

O�01

O�

O��2

O�


O�

O�

P� �

P�

P �

P ��

P �	

P �


P �

P�

P��

P�


P�

P�
.
P�"  FIXME: Discuss. 32 or 64 bits?


P��

P�


P�

P�
L
P�&"> Keep track of last page till which all ots key has been used


P��

P�


P�!

P�$%
B
P�""4 Keep track of number of ots key that has been used


P��&

P�


P�

P� !

P�&

P��"

P�


P�!

P�$%

P�

P��&

P�


P�

P�

P�

P��

P�


P�

P�

P� 

P��

P�


P�

P�

P	�(

P	�� 

P	�


P	�"

P	�%'

P
�&

P
��(

P
�


P
� 

P
�#%

P�$

P��&

P�


P�

P�!#

P�<

P�

P�

P�6

P�9;

P�;

P�

P�

P�5

P�8:

P� 

P�

P�

P�

P�

P�2

P�

P�

P�,

P�/1

Q� �

Q�

Q �

Q ��

Q �	

Q �


Q �

Q�

Q��

Q�	

Q�


Q�

Q�

Q��

Q�


Q�

Q�

Q�

Q��

Q�


Q�

Q�

Q�#

Q�

Q�

Q�

Q�!"

Q� 

Q�

Q�

Q�

Q�

Q�

Q�� 

Q�


Q�

Q�

Q�&

Q��

Q�


Q�!

Q�$%

Q�%

Q��&

Q�


Q� 

Q�#$
'
Q	�( TODO: To be implemented


Q	��%

Q	�


Q	�"

Q	�%'

Q
�<

Q
�

Q
�

Q
�6

Q
�9;

Q�;

Q�

Q�

Q�5

Q�8:

Q� 

Q�

Q�

Q�

Q�

Q�2

Q�

Q�

Q�,

Q�/1

R� �

R�

R �

R �

R �

R �

R �

S� �

S�

S �

S �

S �

S �

S �

T� �

T�

T �!

T �

T �

T �

T � 

U� �

U�

U �

U �

U �

U �

U �

V� �

V�

V �

V ��

V �	

V �


V �

V�

V��

V�	

V�


V�

W� �

W�

W �

W ��

W �	

W �


W �

W�

W��

W�


W�

W�

X� �

X�

X � Header


X ��

X �	

X �


X �

X�

X��

X�


X�

X�

X�!

X��

X�


X�

X� 

X�

X��!

X�	

X�


X�

X�

X��

X�


X�

X�

X�

X��

X�


X�

X�

X�

X��

X�	

X�


X�

X�

X��

X�


X�

X�

X�

X��

X�


X�

X�

Y� �

Y�

Y �

Y ��

Y �

Y �

Y �

Y�+

Y��

Y�

Y�&

Y�)*

Z� �

Z�

Z �"

Z ��

Z �

Z �

Z � !

[� �

[�

[ �

[ ��

[ �

[ �

[ �

[�

[��

[�

[�

[�

[�

[��

[�	

[�


[�

[�

[��

[�


[�

[�

[�!

[��

[�


[�

[� 

\� �

\�

\ �

\ ��

\ �

\ �

\ �

\�;

\�

\� 

\�!6

\�9:
9
\�0+ This is only applicable to genesis blocks


\�

\�

\�+

\�./

\�

\��0

\�


\�

\�

]� �

]�

] �

] ��

] �

] �

] �

]�*

]�

]�

]�%

]�()
9
]�0+ This is only applicable to genesis blocks


]�

]�

]�+

]�./

^� �

^�
B
^ �"4 Address is string only here to increase visibility


^ ��

^ �	

^ �


^ �

^�

^��

^�


^�

^�

_� �

_�

_ �3

_ �

_ �

_ �.

_ �12

`� �

`�

` �

` ��

` �	

` �


` �

`�

`��

`�


`�

`�

`�

`��

`�	

`�


`�

`�

`��

`�	

`�


`�

`�

`��

`�


`�

`�

`�

`��

`�	

`�


`�

` ��

` �


`�

`�

`�

`�

`�

`�

`�

`�

`�'

`�

`�"

`�%&

`	�

`	�

`	�

`	�

`
�

`
�

`
�

`
�

`�*

`�

`�$

`�')

`�

`�

`�

`�

`�-

`�

`�'

`�*,

`�+

`�

`�%

`�(*

`�)

`�

`�#

`�&(

`�,

`�

`�&

`�)+

`�(

`�

`�"

`�%'

` ��	////////


` �

`  �$

`  �

`  �

`  �

`  �"#

` �$

` �

` �

` �

` �"#

` �

` ��$

` �

` �

` �

`��

`�

` �

` ��

` �

` �

` �

`�

`��

`�

`�

`�

`��

`�

` �"
 kyber_pk


` ��

` �

` �

` �

`�" dilithium_pk


`��

`�

`�

`�

`�"
 ecdsa_pk


`��

`�

`�

`�

`��

`�

` �

` ��

` �

` �

` �

`�

`��

`�

`�

`�

`��

`�

` �

` ��

` �

` �

` �

`�

`��

`�

`�

`�

`�

`��

`�

`�

`�

`�

`��

`�

`�

`�

`�4

`�

`�

`�/

`�23

`��

`�

` �

` ��

` �

` �

` �

`�$

`�

`�

`�

`�"#

`�$

`�

`�

`�

`�"#

`��

`�

` �%

` �

` �

` � 

` �#$

`�)

`�

`�

`�$

`�'(

`��

`�

` �'

` �

` �

` �"

` �%&

`�$

`�

`�

`�

`�"#

`�

`��$

`�

`�

`�

`��

`�

` �$

` ��

` �

` �

` �"#

`�$

`�

`�

`�

`�"#

`�$

`�

`�

`�

`�"#

`�'

`��$

`�

`�"

`�%&

`	��

`	�

`	 �

`	 ��

`	 �

`	 �

`	 �

`	�

`	��

`	�

`	�

`	�
0
`	�"  To be used internally by State


`	��

`	�

`	�

`	�

`
��

`
�

`
 �'

`
 ��

`
 �

`
 �"

`
 �%&

`
�

`
��'

`
�

`
�

`
�

`
 ��	

`
 �

`
�

`
�

`
�

`
�

`
�

`
�

`
�

`
�

`
�

`
�

`
�

`
�

`
 ��	

`
 �

`
  � 

	`
  ��

	`
  �

	`
  �

	`
  �

`
��	

`
�

`
 �0

	`
 �

	`
 �

	`
 �+

	`
 �./

`
�#

	`
��0

	`
�

	`
�

	`
�!"

`
�'

	`
��#

	`
�

	`
�"

	`
�%&

`
�<

	`
��'

	`
�

	`
�7

	`
�:;

`
�+

	`
��<

	`
�

	`
�&

	`
�)*

`
�*

	`
��+

	`
�

	`
�%

	`
�()

`
�1

	`
��*

	`
�

	`
�,

	`
�/0

`
�/

	`
��1

	`
�

	`
�*

	`
�-.

`
�0

	`
��/

	`
�

	`
�+

	`
�./
1
`
	�." Support upto 2 decimal places


	`
	��0

	`
	�

	`
	�(

	`
	�+-

`

�6

	`

��.

	`

�

	`

�0

	`

�35

`
�7

	`
��6

	`
�

	`
�1

	`
�46

`
�+

	`
��7

	`
�

	`
�%

	`
�(*

`
�0

	`
��+

	`
�

	`
�*

	`
�-/

`
�.

	`
��0

	`
�

	`
�(

	`
�+-

`
�/

	`
��.

	`
�

	`
�)

	`
�,.

`
�/

	`
��/

	`
�

	`
�)

	`
�,.

`
�/

	`
��/

	`
�

	`
�)

	`
�,.

`
�J

	`
��/

	`
�

	`
�D

	`
�GI

`
�/

	`
��J

	`
�

	`
�)

	`
�,.

`
�:

	`
�

	`
�

	`
�4

	`
�79

`
�/

	`
��:

	`
�

	`
�)

	`
�,.

`
�+

	`
��/

	`
�

	`
�%

	`
�(*

`
�/

	`
��+

	`
�

	`
�)

	`
�,.

`
�9

	`
��/

	`
�

	`
�3

	`
�68

`
�&

	`
��9

	`
�

	`
� 

	`
�#%

`
�

	`
��&

	`
�

	`
�

	`
�

`
��	

`
�

`
 �(

	`
 �

	`
 �

	`
 �#

	`
 �&'

`��

`�

` �

` ��

` �

` �

` �

`�

`��

`�

`�

`�

a� �

a�

a � 

a ��

a �	

a �


a �

a�

a�� 

a�	

a�


a�

a�#

a�

a�

a�

a�!"

a�!

a�

a�

a�

a� 

a�

a�

a�

a�

a�

a�#

a��

a�


a�

a�!"

a�

a��#

a�


a�

a�

a�

a��

a�

a�	

a�

b� �

b�

b �

b ��

b �	

b �


b �

b�

b��

b�	

b�


b�

b�

b��

b�


b�

b�

b�)

b�

b�

b�$

b�'(

b�#

b��)

b�


b�

b�!"

b�

b��#

b�

b�	

b�
?
b�#"1 Keep track of number of pages for vote txn hash


b��

b�


b�

b�!"

c� �

c�

c �#

c ��

c �


c �

c �!"

d� �

d�

d �$

d �

d �

d �

d �"#

e� �

e�

e �

e ��

e �


e �

e �

e�

e��

e�


e�

e�
A
e�"3 Tx hash responsible for the creation of this data


e��

e�	

e�


e�
%
e�" For internal use only


e��

e�

e�	

e�

f� �

f�

f �

f ��

f �


f �

f �

f�

f��

f�	

f�


f�

f�

f��

f�

f�	

f�

g� �

g�

g �

g ��

g �

g �	

g �

g�

g��

g�	

g�


g�

g�

g��

g�

g�	

g�

h� �

h�

h �

h ��

h �	

h �


h �

h�0

h�

h�

h�+

h�./

i� �

i�!

i �" b'NEW' or PRF


i ��#

i �	

i �


i �
+
i�" Expiry Timestamp in seconds


i��

i�


i�

i�

i�" Time to relay


i��

i�


i�

i�

i ��

i �
2
i  �$"" aes256_symkey encrypted by kyber


i  ��

i  �

i  �

i  �"#

i�

i��

i�

i�

i�

i�" nonce


i��

i�


i�

i�
8
i�"* JSON content, encrypted by aes256_symkey


i��

i�	

i�


i�

j� �

j�

j �!

j �

j �

j �

j � 

k� �

k�

k �

k ��

k �


k �

k �

k�

k��

k�	

k�


k�

k�$

k��

k�	

k�


k�"#

l� �	

l�

l �

l ��

l �	

l �


l �

l�$

l��

l�	

l�


l�"#

l�*

l�

l�

l�%

l�()
R
l�	+"D Keeps last N headerhashes, for measurement of timestamp difference


l�	

l�	

l�	&

l�	)*

m�	 �	

m�	

m �	

m �	�	

m �		

m �	


m �	

m�	

m�	�	

m�		

m�	


m�	

n�	 �	

n�	

n �	

n �	�	

n �		

n �	


n �	

n�	

n�	�	

n�	


n�	

n�	

n�	(

n�	�	

n�	

n�	#

n�	&'

o�	 �	

o�	

o �	

o �	�	

o �	


o �	

o �	

o�	

o�	�	

o�		

o�	


o�	

o�	$

o�	�	

o�		

o�	


o�	"#

o�	

o�	�	$

o�	


o�	

o�	

o�	

o�	�	

o�	


o�	

o�	

p�	 �	

p�	

p �	

p �	�	

p �	


p �	

p �	

p�	$

p�	

p�	

p�	

p�	"#

q�	 �	

q�	

q �	

q �	�	

q �	


q �	

q �	

r�	 �	

r�	

r �	

r �	�	

r �		

r �	


r �	

r�	

r�	�	

r�	


r�	

r�	

r�	 

r�	�	

r�	


r�	

r�	

r�	

r�	�	 

r�	


r�	

r�	

r�	3

r�	

r�	

r�	.

r�	12

s�	 �	

s�	

s �	)

s �	

s �	

s �	$

s �	'(

t�	 �	

t�	

t �	

t �	�	

t �		

t �	


t �	

t�	 

t�	�	

t�		

t�	


t�	

t�	%

t�	�	 

t�		

t�	
 

t�	#$

t�	'

t�	�	%

t�	


t�	"

t�	%&

t�	

t�	�	'

t�		

t�	


t�	

t�	

t�	�	

t�		

t�	


t�	

t�	 

t�	�	

t�	

t�	

t�	

t�	

t�	�	 

t�	

t�	

t�	

t �	�	

t �	

t  �	

t  �	�	

t  �	

t  �	

t  �	

t �	#

t �	�	

t �	

t �	

t �	!"

t �	8

t �	�	#

t �	

t �	3

t �	67

t�	�	

t�	

t �	'

t �	�	

t �	

t �	"

t �	%&

t�	&

t�	�	'

t�	

t�	!

t�	$%

t�	-

t�	�	&

t�	

t�	(

t�	+,

t�	+

t�	�	-

t�	

t�	&

t�	)*

t�	6

t�	�	+

t�	

t�	1

t�	45

t �	�		

t �	#

t  �	0

	t  �	�	%

	t  �	

	t  �	+

	t  �	./
1
t �	'" Support upto 2 decimal places


	t �	�	0

	t �	

	t �	"

	t �	%&

t �	5

	t �	�	'

	t �	

	t �	0

	t �	34

t�	�	

t�	

t �	&

t �	�	

t �	

t �	!

t �	$%

t�	

t�	�	&

t�	

t�	

t�	

t�	

t�	�	

t�	

t�	

t�	

t�	

t�	�	

t�	

t�	

t�	

t�	

t�	�	

t�	

t�	

t�	

t�	4

t�	�	

t�	

t�	/

t�	23

t�	

t�	�	4

t�	

t�	

t�	

t �	�		

t �	

t  �	"

	t  �	�	

	t  �	

	t  �	

	t  �	 !

t�	�		

t�	

t �	+

	t �	�	

	t �	

	t �	&

	t �	)*

t�	�		

t�	

t �	)

	t �	�	

	t �	

	t �	$

	t �	'(

t�	'

	t�	�	)

	t�	

	t�	"

	t�	%&

t�	�		

t�	

t �	&

	t �	�	

	t �	

	t �	!

	t �	$%

t�	&

	t�	�	&

	t�	

	t�	!

	t�	$%

t�	&

	t�	�	&

	t�	

	t�	!

	t�	$%

t�	�		

t�	"
1
t �	," Support upto 2 decimal places


	t �	�	$

	t �	

	t �	'

	t �	*+

t�	�		

t�	
1
t �	%" Support upto 2 decimal places


	t �	�	

	t �	

	t �	 

	t �	#$
F
t�	0"4 Convention: All strings must be in capital letters


	t�	

	t�	

	t�	+

	t�	./

t�	.

	t�	�	0

	t�	

	t�	)

	t�	,-

t�	*

	t�	�	.

	t�	

	t�	%

	t�	()

t�	.

	t�	�	*

	t�	

	t�	)

	t�	,-

t�	8

	t�	�	.

	t�	

	t�	3

	t�	67

t�	�	

t�	

t �	!

t �	�	

t �	

t �	

t �	 

t�	

t�	�	!

t�	

t�	

t�	bproto3