import gleam/string_builder.{StringBuilder}
import gleam/bit_string

if erlang {
  /// BitBuilder is a type used for efficiently concatenating bits to create bit
  /// strings.
  ///
  /// If we append one bit string to another the bit strings must be copied to a
  /// new location in memory so that they can sit together. This behaviour
  /// enables efficient reading of the string but copying can be expensive,
  /// especially if we want to join many bit strings together.
  ///
  /// BitBuilder is different in that it can be joined together in constant
  /// time using minimal memory, and then can be efficiently converted to a
  /// bit string using the `to_bit_string` function.
  ///
  pub external type BitBuilder
}

if javascript {
  /// BitBuilder is a type used for efficiently concatenating bits to create bit
  /// strings.
  ///
  /// If we append one bit string to another the bit strings must be copied to a
  /// new location in memory so that they can sit together. This behaviour
  /// enables efficient reading of the string but copying can be expensive,
  /// especially if we want to join many bit strings together.
  ///
  /// BitBuilder is different in that it can be joined together in constant
  /// time using minimal memory, and then can be efficiently converted to a
  /// bit string using the `to_bit_string` function.
  ///
  pub opaque type BitBuilder {
    Leaf(BitString)
    Branch(List(BitBuilder))
  }
}

/// Prepends a bit string to the start of a builder.
///
/// Runs in constant time.
///
pub fn prepend(to: BitBuilder, prefix: BitString) -> BitBuilder {
  append_builder(from_bit_string(prefix), to)
}

/// Appends a bit string to the end of a builder.
///
/// Runs in constant time.
///
pub fn append(to: BitBuilder, suffix: BitString) -> BitBuilder {
  append_builder(to, from_bit_string(suffix))
}

/// Prepends a builder onto the start of another.
///
/// Runs in constant time.
///
pub fn prepend_builder(to: BitBuilder, prefix: BitBuilder) -> BitBuilder {
  append_builder(prefix, to)
}

/// Appends a builder onto the end of another.
///
/// Runs in constant time.
///
pub fn append_builder(
  to first: BitBuilder,
  suffix second: BitBuilder,
) -> BitBuilder {
  do_append_builder(first, second)
}

if erlang {
  external fn do_append_builder(
    to: BitBuilder,
    suffix: BitBuilder,
  ) -> BitBuilder =
    "gleam_stdlib" "iodata_append"
}

if javascript {
  fn do_append_builder(first: BitBuilder, second: BitBuilder) -> BitBuilder {
    Branch([first, second])
  }
}

/// Prepends a string onto the start of a builder.
///
/// Runs in constant time.
///
pub fn prepend_string(to: BitBuilder, prefix: String) -> BitBuilder {
  append_builder(from_string(prefix), to)
}

/// Appends a string onto the end of a builder.
///
/// Runs in constant time.
///
pub fn append_string(to: BitBuilder, suffix: String) -> BitBuilder {
  append_builder(to, from_string(suffix))
}

/// Joins a list of builders into a single builders.
///
/// Runs in constant time.
///
pub fn concat(builders: List(BitBuilder)) -> BitBuilder {
  do_concat(builders)
}

if erlang {
  external fn do_concat(List(BitBuilder)) -> BitBuilder =
    "gleam_stdlib" "identity"
}

if javascript {
  fn do_concat(builders: List(BitBuilder)) -> BitBuilder {
    Branch(builders)
  }
}

/// Creates a new builder from a string.
///
/// Runs in constant time when running on Erlang.
/// Runs in linear time otherwise.
///
pub fn from_string(string: String) -> BitBuilder {
  string
  |> bit_string.from_string
  |> from_bit_string
}

if erlang {
  /// Creates a new builder from a string builder.
  ///
  /// Runs in constant time.
  ///
  pub external fn from_string_builder(StringBuilder) -> BitBuilder =
    "gleam_stdlib" "identity"
}

/// Creates a new builder from a bit string.
///
/// Runs in constant time.
///
pub fn from_bit_string(bits: BitString) -> BitBuilder {
  do_from_bit_string(bits)
}

if erlang {
  external fn do_from_bit_string(BitString) -> BitBuilder =
    "gleam_stdlib" "wrap_list"
}

if javascript {
  fn do_from_bit_string(bits: BitString) -> BitBuilder {
    Leaf(bits)
  }
}

if erlang {
  /// Turns an builder into a bit string.
  ///
  /// Runs in linear time.
  ///
  /// When running on Erlang this function is implemented natively by the
  /// virtual machine and is highly optimised.
  ///
  pub external fn to_bit_string(BitBuilder) -> BitString =
    "erlang" "list_to_bitstring"

  /// Returns the size of the builder's content in bytes.
  ///
  pub external fn byte_size(BitBuilder) -> Int =
    "erlang" "iolist_size"
}
