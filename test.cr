#!/usr/bin/env crystal

def foo(x : Int32, y = 123, z : Int32 = 123) : Int32 | self
  jksldfjklsdf
end

alias PInt32 = Int32*
alias RecArray = Array(Int32) | Array(RecArray)*
type X = Int32*

a = 1
a.is_a?(Int32 | String)
a.is_a? Number*

ptr.as(Int8*)
ptr.as(Array(Int32))

::Kernel.send(name)
::FOO::BAR

class Foo::Bar::Baz
  def self.foo
    "foo"
  end

  def Baz.bar
    "bar"
  end
end

!foobar
~foobar

if foo
  x : Int*
  jksldf
  jksdlf
end

alias Int32ToString = Int32 -> String

def some_method
  something_dangerous
ensure
  # always execute this
end

foo if bar

module Ticker
  def self.on_tick(&callback : Int32 ->)
    boxed_data = Box.box(callback)

    @@box = boxed_data

    LibTicker.on_tick(->(tick, data) {
      data_as_callback = Box(typeof(callback)).unbox(data)
      data_as_callback.call(tick)
    }, boxed_data)
  end
end

Ticker.on_tick do |tick|
  puts tick
end

%( (\))\)\(\) )
jkl
%(\()

%(jkl)

"jksldf'jklsdf" jksdlfjklsdf

%w(foo bar baz)
%w(foo\nbar baz)
%w(foo(bar) baz)
%w(foo\ bar #{baz})
%( foo\ (bar) baz )
%q( foo\ (bar\) #{baz} )

%r(jkl|jksldfjklsdf #{jklsdf}?)

{ name: "Crystal", year: 2011 }, { "this is a key": 1 }

foo12

def foo(x : T(Int32) = 123, y = 123, z = /jksldfsdf/, w = z / y) : Int32 forall T
  T
end

class Object
  def has_instance_var?(name) : Bool
    name.in? {{ @type.instance_vars.map &.name.stringify }}
  end
end

macro dont_update_x
  %x = 1
  puts %x
end

foo x: 1, y: 2

def foo(*foo, **x, y = 2)
  foo x: 1, y: 2
end

x = { foo: 1, bar: 2, BAR: 12 }

xs = [] of Int32 | Int64

def foo
  jksldf
  # jksldf sdf
end

0____123.0___f32
0.123
0x123
0x123u8
0o123u8
0b101u8
0x123f32
0x123e10
123f32
123.123f64
123_E+12_f32
0.123_E-12_432432
0_.012
0_E123
0f32
0i64
0_123.123_E+1_f32
0xFE012D
1_000_000
1_000_000.111_111

:foo

foo.+ bar: 3

"\012jksldfjklsdf"

foo:bar
{foo:"bar"}
foo :"bar"
Foo::Bar
foo? bar: bleh
foo ? 123 : bleh
foo ? 123 : Bleh
foo ? foo : Bleh
foo ? foo : Bleh ? Bleh : Bloo
foo ? foo : Bleh ? ( foo bar: bleh ? :bar : :bleh ) : Bloo*******???
foo ? foo x: 1, y: 2 : Bleh

"#{foo bar: bleh}"

foo = x ? y : z
foo = Foo ? Bar : Baz

puts 1 // 2, 3 / 4

foo /= bar / baz

!Foo
~(foo) + bleh
jklasdf

$~jkl
$_jkljkll + :foo + $1 /a/ $2
$?jkl
$1jkl

123E12

@jkfldsfd
@@jkflds fdlks

@jfkdsl
@@FJKLJKLKK
[ 1, 2, 3 ]

if foo[0]? / jklfds / bjkrlew
  :bar
end

if foo[0]? / jkflds / sjdkflsdf
  :bar jskdlf
end

jksldf = begin
  jksldf
rescue bleh
  jskdlf
end

sjkdflsdf

->(x : Int32, y : Int32) { x + y }

0.. + ..123

'\''

%w(foo\ bar)
%w(foo\\ bar)

%i(foo\ bar)
%i(foo\\ bar)

if x // /bar/ / bleh // boo
  boop
end

def one
  1
end

def plan(begin begin_time, end end_time)
end

plan begin: Time.now, end: 2.days.from_now

close_door unless door_closed?

proc = ->str.count(Char)
proc.call

struct Vector2
  getter x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def - : self
    Vector2.new(-x, -y)
  end

  def +(other : self) : self
    Vector2.new(x + other.x, y + other.y)
  end
end

class Person
  private def say(message)
    puts message
  end
end

abstract class Animal
  abstract def talk
  abstract def walk
end

case num
when .even?
  do_something
when .odd?
  do_something_else
end

case num
when .even? then do_something
when .odd? then do_something_else
end

def some_method(x, y = 1, z = 2, w = 3)
  # do something...
end

some_method 10
some_method 10, z: 10
some_method 10, w: 1, y: 2, z: 3

foo *tuple

lib LibPerson
  fun compute_default_age(age_ptr) : Int32*
end

$? success?

object.[]=(2, 3)

if a = some_expression
  jksldjflksdf
end

@a.try do |a|
  jksldfjksldf
end

x // y // z

foo.begin

foo?(bar)+:bleh
foo? bar:(bleh)

foo.try 1, &.begin
foo /fds/, /bar/, x / y

foo = %w(jkl), "foo", %w(foo bar), x % y % z

foo.x & bar.y

foo bar: 1, baz: 2

foo :bleh, :bloo, %w(foo bar baz)
foo %(jkljkljkl)
foo /bleh/, /bloo/

foo <<-TEXT
jkalsdjfkl
TEXT

print(<<-'FIRST', <<-SECOND)
hello
FIRST
World
SECOND
jksldf

print(<<-'FIRST', <<-SECOND, <<-'THIRD')
hello
FIRST
World
SECOND
jksldf
#{jksldf}
jskdlfjklsdfj
THIRD
jksdlf

foo "jklasdf", 'j', %w(foo bar baz)

'\u{1234}'

foo BAR::BAZ

:"fo\"o#{jkalsdf, 5} bar"

foo.each do
  jklasdf
end

foo ? bar : baz

if foo
  jkl
end

foo.each {
  jklsdfsdf
}

foo &.bar
foo &-> bar

foo & bar

bleh BAR: BAR::BAZ, foo: 123, bar: jklsdf do
  jkl
end
123
macro bar(jklsdf, &block : Foo -> Nil) : self -> Float64
  if foo
    bleh
    bloo
    if bar
      bloo
    end
  end
end

while true
  blerp
end

until false
  blorp
end

foo.each do
  jklasdf
end

foo.each do |fdjksl, bloo = 123|
  bleh
  bloo
end

get :doo do
  jklsdf
end

array
array = [0, 1, 2]

$1
$?

123.123
123.123f32

0x23u8
0o123u8
0b111u8
123u8

:unquoted_symbol
:"quoted symbol"
:"a"

:question?
:exclamation!

foo.each { |bleh|
  { 1, 2 }
  jksdlfjksldf
  jksldf
  jlksdf
  { 3, 4 }
}

foo +
  bar

crystal_VERSION
ARGF

acrystal_VERSION
aARGF

foo = /bar/
foo = /bar/

foo /= x / y
foo /= x % y
foo /= /=/ // // / bleh / bloop

foo = /foo|bar/

foo = /h(e+)llo/
foo =~ /\d+/ / /foo/ // bleh
foo = /あ/

foo //= jkl / bar

if foo /foo/ =~ bleh
  /asdf/
end

def foo(jkalsdfasdf)
  /asdf/
end

/asdf/

/\//                  # slash
/\\/                  # backslash
/\b/                  # backspace
/\e/                  # escape
/\f/                  # form feed
/\n/                  # newline
/\r/                  # carriage return
/\t/                  # tab
/\v/                  # vertical tab
/\123/                # octal ASCII character
/\x12/                # hexadecimal ASCII character
/\u{1324}/            # hexadecimal unicode character
/\u{1111 AFFFFF 123}/ # hexadecimal unicode characters

"\u{1234}"

/a(sd)f/.match("_asdf_")                     # => #<Regex::MatchData "asdf" 1:"sd">
/a(sd)f/.match("_asdf_").try &.[1]           # => "sd"
/a(?<grp>sd)f/.match("_asdf_")               # => #<Regex::MatchData "asdf" grp:"sd">
/a(?<grp>sd)f/.match("_asdf_").try &.["grp"] # => "sd"

/a\Qjklsdfjklsdf|jksldf\Ejksl(?imx)dfjlksdf|jksdl#{jksdlf + 123}fjkls{{ foo + 123 }}df/
/jskldf{,123}\123\g{foo}\g<foo>/

/foo|bar/.match("foo")     # => #<Regex::MatchData "foo">
/foo|bar/.match("bar")     # => #<Regex::MatchData "bar">
/_(x|y)_/.match("_x_")     # => #<Regex::MatchData "_x_" 1: "x">
/_(x|y)_/.match("_y_")     # => #<Regex::MatchData "_y_" 1: "y">
/_(x|y)_/.match("_(x|y)_") # => nil
/_(x|y)_/.match("_(x|y)_") # => nil
/_._/.match("_x_")         # => #<Regex::MatchData "_x_">
/_[xyz]_/.match("_x_")     # => #<Regex::MatchData "_x_">
/_[a-z]_/.match("_x_")     # => #<Regex::MatchData "_x_">
/_[^a-z[:alnum:]]_/.match("_x_")    # => nil
/_[^a-wy-z]_/.match("_x_") # => #<Regex::MatchData "_x_">

alias RecArray = Array(Int32) | Array(RecArray)

%r((/)())   # => /(\/)/
%r[[/][]]   # => /[\/]/
%r[[/\][]]  # => /[\/]/
%r{{/}{}}   # => /{\/}/
%r{\{/\}{}} # => /{\/}/
%r<</><>>   # => /<\/>/
%r|/\||     # => /\//

%(( jklj\n ))  #foo
jkl
%[ [ [ ] \[jklj\n ]]  #foo
jkl
%{{ jklj\n }}  #foo
jkl
%<< jklj\n >>  #foo
jkl
%|jkfldsjfdlks\|\)jklasjdf|  #foo
"foo\("  #foo

"jk\[\]\{lasdf#{1}\#{2}"

"\"" # double quote
"\\" # backslash
"\e" # escape
"\f" # form feed
"\n" # newline
"\r" # carriage return
"\t" # tab
"\v" # vertical tab
"\u0041" # == "A"
"\u{41}" # == "A"
"hello " \
  "sdfjklsdf" \
  "jksldfjklsdf" \
  "world, " \
  "no newlines" # same as "hello world, no newlines"

foo = "hello
sdfsdfds
jksldf world \"
jklsdf" + :foo

x + " foo " +
  " bar " +
  jskldfjklsdf +
  jaksldf
jksldfjsdf

# Supports double quotes and nested parentheses
%(hello ("world")) # same as "hello (\"world\")"

# Supports double quotes and nested brackets
%[hello ["world"]] # same as "hello [\"world\"]"

# Supports double quotes and nested curlies
%{hello {"world"}} # same as "hello {\"world\"}"

# Supports double quotes and nested angles
%<hello <"world">> # same as "hello <\"world\">"

unless foo + bar - bleh
  jklasdf
end

<<-STRING # => "Hello\n  world"
Hello
world
<F5>
    jklasdfasdf
jkalsdfasdf
#{jklasdfasdf}
jklsdfsdf
STRING

upcase <<-SOME, "bleh" # => jkl
jklsdf
SOME

upcase(<<-SOME, :bleh, "bleh", 'b', /bleh/ / foo) # => "HELLO"
hello
SOME

upcase(<<-'SOME', "bleh")  # => "HELLO"
foo
bar
SOME

<<-HERE
hello \n \#{world}
HERE

<<-HERE
hello \n #{world}
HERE

foo = <<-'HERE' # => "hello \\n \#{world}"
hello \n #{world}
HERE

foo = <<-'HERE' # => jklasdf
hello \n #{wordl}
HERE

:"jklsdfjklsdf"

a = 1
b = 2
"sum = #{foo { |a, b| jksldfjklsdf + {{ foo { |x| x ** 2 } }} + 123 } } jksldfsdf"
"sum = #{foo { |a, b| jskldf { |x, y| x + {{ 123 }} + 123 } }} + 1" # "sum = 3"

$1?
$1232321321?

# Octal escape sequences
"\101" # # => "A"
"\12"  # # => "\n"
"\1"   # string with one character with code point 1
"\377" # string with one byte with value 255

# Hexadecimal escape sequences
"\x41" # # => "A"
"\xFF" # string with one byte with value 255

module Json(Int32)
  private property? @@jkl : Int32 = 123

  alias Type =
    Nil |
    Bool |
    Int64 |
    Float64 |
    String |
    Array(Type) |
    Hash(String, Type)

  require "jksldf"

  if @foo
    @foojklasdfasdf
    module Foo

    end
  end

  @jklasdf
end

class Foo
  def []?(foo, bar)
    @foo
  end

  if @foo
    jklasdfasdf
  end

  def !~
    jksldf
    jksdlf
  end

  def begin?
  end

  def ===
  end
end

case array
in [1, 2]
in [1, 2, a]
  puts a
end

case exp
in [1, a]
  puts a
else
  puts "No match"
  "'"
end

if null_checked_value = array[3]?
  /foo/
  puts value + 2
  exit 0
end

if foo =~ /bar/
  bleh
end

if foo =~ /bar/
  bleh
end

foo ?
  bar : Bleh

if foo
  {% if BIG_ENDIAN == true %}
    hi = pointerof(word).as(Byte*)
    lo = hi + 1
  {% else %}
    lo = pointerof(word).as(Byte*)
    hi = lo + 1
  {% end %}

  bleh
end

foo.self
foo.nil
foo.__FILE__
foo.true.true
  .false
  .jaskldf

self
nil
__FILE__
true

x = 1 || "a"
z = case x
when Int32
  true
when String
  false
end

x = 1 || "a"
z = case x
in Int32
  true
in String
  false
end

typeof(z) # => Bool

# result:
if null_checked_value = array[3]?
  puts value + 2
  exit 0
end

foo.bar?

value : Int32 | Nil = 3

# expected:
if null_checked_value = value
  puts value + 2
  exit 0
end

if foo
  bleh
end

foo = (bar,
  bleh,
  blerp,
  blorp,
  bloo)

foo = {
  x: 1,
  y: 2,
  z: 3
}

foo..
bar

foo = (
  bleh,
  bloo,
  bar +
    bleh -
    bloo * fjdkls,
  jskdlf
)

foo bar,
  baz,
  bleh,
  123

record DelimiterState,
  kind : Symbol,
  nest : Char | String,
  _end : Char | String,
  open_count : Int32,
  heredoc_indent : Int32,
  allow_escapes : Bool

@Foo
@_FDOISfdsfds_123
@f123
@fds
@@foo

foo._Bar

FOo12__3

{foo:bar}
foo:"bar"
Foo::Bar
foo?bar:bleh

foo.begin

foo?(bar) :bleh
foo? bar:(bleh)

'\u{1234}'

:"foo#{jkalsdf} bar"

%foo
x %foo
{% %foo %}

foo = :[]?
foo = :<<
bar **= :+
:&+

foo + bar

:**,
  :+,
  :[]?,
  :&+,
  :<<,
  :<=>,
  :!,
  true

foo = bar(bleh, blerp,
  jklsdf, fjdklsajfkdlsa)

macro define_method(name, content)
  def bleh(sdf)
    bleh
  end
end

private def dump_or_inspect(io)
  io << '"'
  dump_or_inspect_unquoted(io) do |char, error|
    yield char, error
  end
  io << '"'
end

if foo
end

private annotation MyAnnotation
end

annotation MyAnnotation
end

"\\'foo\\\\\\\""

@[MyAnnotation("foo")]
@[MyAnnotation(123)]
@[MyAnnotation(123)]

foo[123]

def annotation_read
  {% for ann, idx in @def.annotations(MyAnnotation) %}
    pp "Annotation {{ idx }} = {{ ann.id + bleh[0]? }}"
    {{ bleh[0] }}
  {% end %}
end

class Foo
  @[MyAnnotation(123)]
  def boo
    bleh
  end
end

annotation_read

x = if true
  5
else
  10
end

x + if true
  5
else
  10
end

case x
in foo
  5
in [Foo, Bar]
  jklasdf
end

x = if true 5 else 10 end

x = if true
  5
else
  10
end

x = "if"
bar

foo = ([%{jk(l[{}]}])

foo(
  bar(
    {
      x: 1,
      y: 2,
      "do": 3,
      "foo bar": 4
    }
  )
)

# This generates:
#
#     def foo
#       1
#     end
define_method foo, 1

bar.foo= 123

foo[0]= 123

:+
:-
:*
:**
:/
://
:==
:===
:=~
:!=
:!~
:!
:<=>
:<=
:<<
:<
:>=
:>>
:>
:&+
:&-
:&**
:&*
:&
:|
:^
:~
:%
:[]=
:[]?
:[]

true

foo =~ /bar/
bleh

foo = true ? /foo/ : /bar/

foo if bleh

foo # => 1

class Foo(Int32)
  macro emphasize(value)
    "***+#{ {{value}} }***"
  end

  def yield_with_self
    with self yield
  end
end

Foo.new.yield_with_self { emphasize(10) } # => "***10***"

abstract class Foo
  macro emphasize(value)
    "***#{ {{value}} }***"
  end
end

Foo(Int32).emphasize(10) # => "***10***"

# This generates:
#
#     def :foo
#       1
#     end
define_method :foo, 1

macro define_method(name, content)
  def {{name.id}}
    {{content}}
  end
end

# This correctly generates:
#
#     def foo
#       1
#     end
define_method :foo, 1

macro define_class(module_name, class_name, method, content)
  module {{module_name}}
    class {{class_name}}
      def initialize(@name : String)
      end

      def {{method}}
        {{content}} + @name
      end
    end
  end
end

:"foo bar"

p Foo::Bar.new("John").say # => "hi John"

class Foo
  if bar
    foo
  else
  end
  bleh
end

if foo
  if bar
    foo
  else
    bar
  end
  bleh
end

if 1
  if 2
  else
  end
end

macro define_method(name, content)
  def {{name}}
    if content == 1
      "one"
    elsif content == 2
      "two"
    else
      content
    end
  end
end

macro define_method(name, content)
  def {{name}}
    {% if content == 1 %}
      "one"
    {% elsif content == 2 %}
      "two"
    {% else %}
      {{content}}
    {% end %}
  end
end

define_method foo, 1
define_method bar, 2
define_method baz, 3

foo # => one
bar # => two
baz # => 3

{% if env("TEST") %}
  puts "We are in test mode"
{% end %}

{{foo}} * bar

macro define_constants(count)
  {% for i in (1..count) %}
    PI_{{i.id}} = Math::PI * {{i}} * jklsdf
  {% end %}
end

foo = :+ if bleh
bar

define_constants(3)

PI_1 # => 3.14159...
PI_2 # => 6.28318...
PI_3 # => 9.42477...

macro define_dummy_methods(names)
  {% for name, index in names %}
    def {{name.id}}
      {{index}}
    end
  {% end %}
end

define_dummy_methods [foo, bar, baz]

foo # => 0
bar # => 1
baz # => 2

macro define_dummy_methods(hash)
  {% for key, value in hash %}
    def {{key.id}}
      {{value}}
    end
  {% end %}
end

define_dummy_methods({foo: 10, bar: 20})
foo # => 10
bar # => 20

{% for name, index in ["foo", "bar", "baz"] %}
  def {{name.id}}
    {{index}}
  end
{% end %}

foo(foo: "bleh", bleh: true)

foo # => 0
bar # => 1
baz # => 2

macro define_dummy_methods(*names)
  {% for name, index in names %}
    def {{name.id}}
      {{index}}
    end
  {% end %}
end

define_dummy_methods foo, bar, baz

foo # => 0
bar # => 1
baz # => 2

macro println(*values)
  print {{*values}}, '\n'
end

foo = :foo

foo = :"
foo
"

println 1, 2, 3 # outputs 123\n

if true
  5
else
  10
end

x = if true
  5
else
  10
end

while true
  if foo
    bar
  else
    bleh
  end
end

def foo
  until true
    do_something
  end
end

macro add_describe_methods
  def describe
    "Class is: " + {{ @type.stringify }}
  end

  def self.describe
    "Class is: " + {{ @type.stringify }}
  end
end

def foo
  bleh
rescue e : Foo
  bloo
end

class Foo
  add_describe_methods
end

Foo.new.describe # => "Class is Foo"
Foo.describe     # => "Class is Foo"

module Foo
  def Foo.boo(arg1, arg2)
    {% @def.receiver %} # => Foo
    {% @def.name %}     # => boo
    {% @def.args %}     # => [arg1, arg2]
  end
end

Foo.boo(0, 1)

VALUES = [1, 2, 3]

{% for value in VALUES %}
  puts {{value}}
{% end %}

macro define_macros(*names)
  {% for name in names %}
    macro greeting_for_{{name.id}}(greeting)
      {% if greeting == "hola" %}
        "¡hola {{name.id}}!"
      {% else %}
        "\{{greeting.id}} {{name.id}}"
      {% end %}
    end
  {% end %}
end

macro define_macros(*names)
  {% for name in names %}
    macro greeting_for_{{name.id}}(greeting)
      \{% if greeting == "hola" %}
        "¡hola {{name.id}}!"
      \{% else %}
        "\{{greeting.id}} {{name.id}}"
      \{% end %}
    end
  {% end %}
end

{%  %}

# This generates:
#
#     macro greeting_for_alice
#       {% if greeting == "hola" %}
#         "¡hola alice!"
#       {% else %}
#         "{{greeting.id}} alice"
#       {% end %}
#     end
#     macro greeting_for_bob
#       {% if greeting == "hola" %}
#         "¡hola bob!"
#       {% else %}
#         "{{greeting.id}} bob"
#       {% end %}
#     end
define_macros alice, bob

greeting_for_alice "hello" # => "hello alice"
greeting_for_bob "hallo"   # => "hallo bob"
greeting_for_alice "hej"   # => "hej alice"
greeting_for_bob "hola"    # => "¡hola bob!"

%w(foo bar).each do |bleh|
  bleh
end

foo = <<-TEXT
bleh
bloo blerp
TEXT

foo.each do |bleh|
  bleh
end

foo |
  bar

foo ||
  bar

foo /
  bar

foo //
  bar

bleh

foo :
  Bleh

foo &
  bar

foo &&
  bar

foo ?
  bar : Foo
bleh

foo ? bar : bleh

foo?
bar

foo *
  bar
fjkdls

bleh

foo *
  bar

foo =
  bar

foo +=
  bar

foo =~
  bar

foo \
  bar

foo &=
  jlkasdf

foo !~
  bleh

foo &+
  bleh

foo -
  bar

foo ?
  bar :
  bleh

foo +
  bar +
  bleh

foo ^
  bar

foo ^=
  bar

foo ==
  true

foo =~
  true

foo ===
  bleh

foo !=
  true

foo.each do
  bleh
end

foo(
  foo,
  bar,
  bloop
)

foo(bleh,
  bloo,
  bleh,
  boop)

foo = [
  foo,
  bar,
  bloop,
]

foo = [foo,
  bar,
  bloop]

foo = {
  foo,
  bar,
  bloop,
}

foo = {foo,
  bar,
  bloop}

foo = {
  foo +
    bar -
    bleh,
  blerp,
  jksldf if true,
  jksldf + if true
    jksldfjskdlf
  else
    10
  end,
  jksldfjksldf
}

%w(foo bar).each do
  bleh
end

%w(foo bar).each do
  %w(baz qux).each do
    bleh
  end
end

[1, 2, 3].each do
  bleh
end

:_!

'\''
'a'
'"'
'\a'
'\\'
'\t'
'\u12FD'
"\""
"\`"
'\''

`\``

{foo?: 1, _1?: 2, FOO: 3, _FOO_?: 4}
{"foo": 1, "bar": 2, _A?: 1}

[1, 2, 3].each do
  bleh

  [4, 5, 6].each do |j|
  end

  [1, 2, 3].each do |i|
    [1, 2, 3].each do |j|
      bleh
    end
  end
end

if foo || bar || baz || bing
  puts "foo"
end

[1, 2, 3].each do |i|
  [4, 5, 6].each do |j|
    foo
  end
end

foo.each { |i|
  bleh
}

foo.each {
  bleh
}

%w(foo bar).each {
  bleh
}

%w(foo bar).each {
  %w(baz qux).each {
  }
}

x = {
  x: 1,
  y: 2,
}

[1, 2, 3].each {
  bleh
}

[1, 2, 3].each {
  bleh
}

[1, 2, 3].each {
  bleh

  [4, 5, 6].each { |j|
  }

  [1, 2, 3].each { |i|
    [1, 2, 3].each { |i|
      bleh
    }
  }
}

[1, 2, 3].each { |i|
  [4, 5, 6].each { |j|
    foo
  }
}

%w(foo bar).each do
  bleh
end

%w(foo bar).each do |bleh|
  bleh
end

foo = "bar" \
  "baz"

method_call one,
  two,
  three

method_call(
  other_method_call (
    foo
  )
)

method_call do
  something
  something_else
end

macro define_macros(*names)
  {% for name in names %}
    macro greeting_for_{{name.id}}(greeting)
      # name will not be available within the verbatim block
      \{% name = {{name.stringify}} %}

      {% verbatim do %}
        {% if greeting == "hola" %}
          "¡hola {{name.id}}!"
        {% else %}
          "{{greeting.id}} {{name.id}}"
        {% end %}
      {% end %}
    end
  {% end %}
end

# This generates:
#
#     macro greeting_for_alice
#       {% name = "alice" %}
#       {% if greeting == "hola" %}
#         "¡hola alice!"
#       {% else %}
#         "{{greeting.id}} alice"
#       {% end %}
#     end
#     macro greeting_for_bob
#       {% name = "bob" %}
#       {% if greeting == "hola" %}
#         "¡hola bob!"
#       {% else %}
#         "{{greeting.id}} bob"
#       {% end %}
#     end
define_macros alice, bob

greeting_for_alice "hello" # => "hello alice"
greeting_for_bob "hallo"   # => "hallo bob"
greeting_for_alice "hej"   # => "hej alice"
greeting_for_bob "hola"    # => "¡hola bob!"

require "http/server"

server = HTTP::Server.new do |context|
  context.response.content_type = "text/plain"
  context.response.print "Hello world! The time is #{Time.local}"
end

address = server.bind_tcp 8080
puts "Listening on http://#{address}"
server.listen

# file: help.cr
require "option_parser"

%(jklasdf)
%|bleh|
%[bleh]
%{bleh}
%<bleh>

OptionParser.parse do |parser|
  parser.banner = "Welcome to The Beatles App!"

  parser.on "-v", "--version", "Show version" do
    puts "version 1.0"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

foo?[] + /jksldf/ // jskdlf

# file: twist_and_shout.cr
require "option_parser"

the_beatles = [
  "John Lennon",
  "Paul McCartney",
  "George Harrison",
  "Ringo Starr",
]
shout = false

option_parser = OptionParser.parse do |parser|
  parser.banner = "Welcome to The Beatles App!"

  parser.on "-v", "--version", "Show version" do
    puts "version 1.0"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
  parser.on "-t", "--twist", "Twist and SHOUT" do
    shout = true
  end
end

members = the_beatles
members = the_beatles.map &.upcase if shout

puts ""
puts "Group members:"
puts "=============="
members.each do |member|
  puts member
end

module Foo
  class Error < Exception; end
end

# :nodoc:
CHAR_TO_DIGIT = begin
  table = StaticArray(Int8, 256).new(-1_i8)
  10_i8.times do |i|
    table.to_unsafe[48 + i] = i
  end
  26_i8.times do |i|
    table.to_unsafe[65 + i] = i + 10
    table.to_unsafe[97 + i] = i + 10
  end
  table
end

{ jksldfsdf } {%  %}

a,
  b,
  c,
  d,
  e

foo?
bar

foo!
bar

class Array
  def self.elem_type(typ)
    if typ.is_a?(Array)
      elem_type(typ.first)
    else
      typ
    end
  end
end

next = [1, ["b", [:c, ['d']]]]
flat = Array(typeof(Array.elem_type(nest))).new
typeof(nest)
typeof(flat)

# :nodoc:
record ToU64Info,
  value : UInt64,
  negative : Bool,
  invalid : Bool

def =~(regex : Regex)
  match = regex.match(self)
  $~ = match
  match.try &.begin(0)
end

foo = begin
  jksldf
end

@def = "bleh"

Foo*
jksldfsdf
jksldf
Foo?
jksldf
jskldf

def []?(regex : Regex, group) : Int?
  match[group]? if match
  jksldf
  jklsdf
  match = match(regex)
end

def foo : Int*
  jksldfjksldf
  jskldf if jksldf
  jksldf
end

# :ditto:
def rindex(search : Regex, offset = size - 1)
  offset += size if offset < 0
  return nil unless 0 <= offset <= size

  match_result = nil
  scan(search) do |match_data|
    break if (index = match_data.begin) && index > offset
    match_result = match_data
  end

  match_result.try &.begin
end

def foo
  foo = $~
  bar
end

require "file_utils"

logger = if Lucky::Env.test?
  # Logs to `tmp/test.log` so you can see what's happening without having
  # a bunch of log output in your specs results.
  FileUtils.mkdir_p("tmp")
  Dexter::Logger.new(
    io: File.new("tmp/test.log", mode: "w"),
    level: Logger::Severity::DEBUG,
    log_formatter: Lucky::PrettyLogFormatter
  )
elsif Lucky::Env.production?
  # This sets the log formatter to JSON so you can parse the logs with
  # services like Logentries or Logstash.
  #
  # If you want logs like in development use `Lucky::PrettyLogFormatter`.
  Dexter::Logger.new(
    io: STDOUT,
    level: Logger::Severity::INFO,
    log_formatter: Dexter::Formatters::JsonLogFormatter
  )
else
  # For development, log everything to STDOUT with the pretty formatter.
  Dexter::Logger.new(
    io: STDOUT,
    level: Logger::Severity::DEBUG,
    log_formatter: Lucky::PrettyLogFormatter
  )
end

Lucky.configure do |settings|
  settings.logger = logger
end

Avram::Repo.configure do |settings|
  settings.logger = logger
end

module Colorize
  alias Color = ColorANSI | Color256 | ColorRGB

  enum ColorANSI
    Default      = 39
    Black        = 30
    Red          = 31
    Green        = 32
    Yellow       = 33
    Blue         = 34
    Magenta      = 35
    Cyan         = 36
    LightGray    = 37
    DarkGray     = 90
    LightRed     = 91
    LightGreen   = 92
    LightYellow  = 93
    LightBlue    = 94
    LightMagenta = 95
    LightCyan    = 96
    White        = 97

    def fore(io : IO) : Nil
      to_i.to_s io
    end

    def back(io : IO) : Nil
      (to_i + 10).to_s io
    end
  end
end

jksdlfsdf

jksldf

x = if foo
  jksldfjklsdf
  asjkdflasdf
  ajksldf
end

x = [
  if foo
    bleh
  else
    bloo
  end,
  if blerp
    blorp
  else
    fjkdlsjfklds
  end,
]

x = case y
when 1
  "foo"
when 2
  "bar"
when 3 then "baz"
when 4
  "bleh"
  "bloo"
when 5 then
  "jskdlf"
else
  "blerp"
end

true if bleh

last_color_is_default =
  @@last_color[:fore] == ColorANSI::Default &&
  @@last_color[:back] == ColorANSI::Default &&
  @@last_color[:mode] == 0

class Object
  macro const_get(const)
    {% begin %}      # <--- %} not highlighted
      {{@type}}::{{const.id}}
    {% end %}        # <--- end not highlighted
  end # <--- end highlighted like begin instead of like macro
end

spawn do
  {{times}}.times do |i|
    puts "#{{{which}}.colorize {{color { |a, b| a + b }}}} producer sent: #{i.colorize {{color}}}"
    channel.send(Product.new("#{{{which}}}: #{i}", {{color}}))
    sleep {{producer_time}}
  end
end

foo = "#{ jksldfsdf { |b, a| jksldf } }"

def self.each
  {% for member in @type.constants %}
    {% unless @type.has_attribute?("Flags") && %foo && %w(none all).includes?(member.stringify.downcase) %}
      yield new({{@type.constant(member)}}), {{@type.constant(member)}}
    {% end %}
  {% end %}
end

NULL = {% if flag?(:win32) %}
  "NUL"
{% else %}
  "/dev/null"
{% end %}

def self.each
  @type.constants.each do |member|
  end
end

foo
  .bar
  .baz
..jksldfsdf

foo..bar

lib Foo
  fun bar
end

x = {
  end: 123,
  rescue: jskldf
}

%r((/)()) # => /(\/)/
%r[[/][]] # => /[\/]/
%r{{/}{}} # => /{\/}/
%r<</><>> # => /<\/>/
%r|/\||   # => /\//

%{{\{\}}}

alias Formatter = Severity, Time, String, String, IO -> self

class Foo < Bar
  jksldfjlk
end

private DEFAULT_FORMATTER = Formatter.new do |severity, datetime, progname, message, io|
  label = severity.unknown? ? "ANY" : severity.to_s
  io << label[0] << ", [" << datetime << " #" << Process.pid << "] "
  io << label.rjust(5) << " -- " << progname << ": " << message
end

# Floating indentation samples:

# jksldf =
#   begin
#     jksldf
#   rescue bleh
#     jskdlf
#   end

# <<-STRING # => "  Hello\n    world"
# Hello
# world
#   STRING

#   (foo) +
#     bar

# <<-SOME.upcase # => "HELLO"
#       hello
#       SOME

#     def upcase(string)
#       string.upcase
#     end

# def []?(regex : Regex,
#   group) : Int?
# match[group]? if match
# jksdlf
# jskldf
# jksldfjklsdf
# end

# method_call one,
# two {
#   three
# }

# method_call one,
# two do
#   three
# end

# record Color256,
# value : UInt8 do
#   def fore(io : IO) : Nil
#     io << "38;5;"
#     value.to_s io
#   end

#   def back(io : IO) : Nil
#     io << "48;5;"
#     value.to_s io
#   end
# end

# record ColorRGB,
# red : UInt8,
# green : UInt8,
# blue : UInt8 do
#   def fore(io : IO) : Nil
#     io << "38;2;"
#     io << red << ";"
#     io << green << ";"
#     io << blue
#   end

#   def back(io : IO) : Nil
#     io << "48;2;"
#     io << red << ";"
#     io << green << ";"
#     io << blue
#   end
# end

# x = if foo
#   record ColorRGB,
#   red : UInt8,
#   green : UInt8,
#   blue : UInt8 do
#     def fore(io) : Nil
#       io << "bleh"
#     end

#     def back
#       jksldf
#     end
#   end
# end

# foo =
#   begin
#     jksldfjsdf
#   end

# x = case y
# when 1
#   "foo"
# when 2
#   "bar"
# when 3 then "baz"
# when 4
#   "bleh"
#   "bloo"
# when 5 then
#   "jskdlf"
# else
#   "blerp"
# end
