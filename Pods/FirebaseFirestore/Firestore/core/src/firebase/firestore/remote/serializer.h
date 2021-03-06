/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_SERIALIZER_H_
#define FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_SERIALIZER_H_

#include <cstdint>
#include <cstdlib>
#include <memory>
#include <string>
#include <vector>

#include "Firestore/Protos/nanopb/google/firestore/v1/document.nanopb.h"
#include "Firestore/Protos/nanopb/google/firestore/v1/firestore.nanopb.h"
#include "Firestore/core/src/firebase/firestore/core/query.h"
#include "Firestore/core/src/firebase/firestore/model/database_id.h"
#include "Firestore/core/src/firebase/firestore/model/document.h"
#include "Firestore/core/src/firebase/firestore/model/document_key.h"
#include "Firestore/core/src/firebase/firestore/model/field_value.h"
#include "Firestore/core/src/firebase/firestore/model/maybe_document.h"
#include "Firestore/core/src/firebase/firestore/model/no_document.h"
#include "Firestore/core/src/firebase/firestore/model/snapshot_version.h"
#include "Firestore/core/src/firebase/firestore/nanopb/reader.h"
#include "Firestore/core/src/firebase/firestore/nanopb/writer.h"
#include "Firestore/core/src/firebase/firestore/util/hard_assert.h"
#include "Firestore/core/src/firebase/firestore/util/status.h"
#include "absl/base/attributes.h"
#include "absl/strings/string_view.h"

namespace firebase {
namespace firestore {

namespace local {
class LocalSerializer;
}

namespace remote {

template <typename T>
T* MakeArray(size_t count) {
  return reinterpret_cast<T*>(calloc(count, sizeof(T)));
}

/**
 * @brief Converts internal model objects to their equivalent protocol buffer
 * form, and protocol buffer objects to their equivalent bytes.
 *
 * Methods starting with "Encode" convert from a model object to a nanopb
 * protocol buffer, and methods starting with "Decode" convert from a nanopb
 * protocol buffer to a model object
 *
 * For encoded messages, FreeNanopbMessage() must be called on the returned
 * nanopb proto buffer or a memory leak will occur.
 */
// TODO(rsgowman): Original docs also has this: "Throws an exception if a
// protocol buffer is missing a critical field or has a value we can't
// interpret." Adjust for C++.
class Serializer {
 public:
  /**
   * @param database_id Must remain valid for the lifetime of this Serializer
   * object.
   */
  explicit Serializer(
      const firebase::firestore::model::DatabaseId& database_id);

  /**
   * Encodes the string to nanopb bytes.
   *
   * This method allocates memory; the caller is responsible for freeing it.
   * Typically, the returned value will be added to a pointer field within a
   * nanopb proto struct. Calling pb_release() on the resulting struct will
   * cause all proto fields to be freed.
   */
  static pb_bytes_array_t* EncodeString(const std::string& str);

  /**
   * Decodes the nanopb bytes to a std::string. If the input pointer is null,
   * then this method will return an empty string.
   */
  static std::string DecodeString(const pb_bytes_array_t* str);

  /**
   * Encodes the std::vector to nanopb bytes. If the input vector is empty, then
   * the resulting return bytes will have length 0 (but will otherwise be valid,
   * i.e. not null.)
   *
   * This method allocates memory; the caller is responsible for freeing it.
   * Typically, the returned value will be added to a pointer field within a
   * nanopb proto struct. Calling pb_release() on the resulting struct will
   * cause all proto fields to be freed.
   */
  static pb_bytes_array_t* EncodeBytes(const std::vector<uint8_t>& bytes);

  /**
   * Decodes the nanopb bytes to a std::vector. If the input pointer is null,
   * then this method will return an empty vector.
   */
  static std::vector<uint8_t> DecodeBytes(const pb_bytes_array_t* bytes);

  /**
   * Release memory allocated by the Encode* methods that return protos.
   *
   * This essentially wraps calls to nanopb's pb_release() method.
   */
  static void FreeNanopbMessage(const pb_field_t fields[], void* dest_struct);

  /**
   * @brief Converts the FieldValue model passed into bytes.
   *
   * Any errors that occur during encoding are fatal.
   */
  static google_firestore_v1_Value EncodeFieldValue(
      const model::FieldValue& field_value);

  /**
   * @brief Converts from nanopb proto to the model FieldValue format.
   *
   * @param reader The Reader object. Used only for error handling.
   * @return The model equivalent of the bytes. On error, the return value is
   * unspecified.
   */
  // TODO(rsgowman): Once the proto is read, the only thing the reader object is
  // used for is error handling. This seems questionable. We probably need to
  // rework error handling. Again. But we'll defer that for now and continue
  // just passing the reader object.
  static model::FieldValue DecodeFieldValue(
      nanopb::Reader* reader, const google_firestore_v1_Value& proto);

  /**
   * Encodes the given document key as a fully qualified name. This includes the
   * databaseId associated with this Serializer and the key path.
   */
  std::string EncodeKey(
      const firebase::firestore::model::DocumentKey& key) const;

  /**
   * Decodes the given document key from a fully qualified name.
   */
  firebase::firestore::model::DocumentKey DecodeKey(
      nanopb::Reader* reader, absl::string_view name) const;

  /**
   * @brief Converts the Document (i.e. key/value) into bytes.
   *
   * Any errors that occur during encoding are fatal.
   */
  google_firestore_v1_Document EncodeDocument(
      const model::DocumentKey& key, const model::ObjectValue& value) const;

  /**
   * @brief Converts from nanopb proto to the model Document format.
   *
   * @param reader The Reader object. Used only for error handling.
   * @return The model equivalent of the bytes or nullopt if an error occurred.
   * @post (reader->status().ok() && result) ||
   * (!reader->status().ok() && !result)
   */
  std::unique_ptr<model::MaybeDocument> DecodeMaybeDocument(
      nanopb::Reader* reader,
      const google_firestore_v1_BatchGetDocumentsResponse& response) const;

  /**
   * @brief Converts the Query into bytes, representing a
   * firestore::v1::Target::QueryTarget.
   *
   * Any errors that occur during encoding are fatal.
   */
  google_firestore_v1_Target_QueryTarget EncodeQueryTarget(
      const core::Query& query) const;

  std::unique_ptr<model::Document> DecodeDocument(
      nanopb::Reader* reader, const google_firestore_v1_Document& proto) const;

  static void EncodeObjectMap(const model::ObjectValue::Map& object_value_map,
                              uint32_t map_tag,
                              uint32_t key_tag,
                              uint32_t value_tag);

  static google_protobuf_Timestamp EncodeVersion(
      const model::SnapshotVersion& version);

  static google_protobuf_Timestamp EncodeTimestamp(
      const Timestamp& timestamp_value);

  static model::SnapshotVersion DecodeSnapshotVersion(
      nanopb::Reader* reader, const google_protobuf_Timestamp& proto);

  static Timestamp DecodeTimestamp(
      nanopb::Reader* reader, const google_protobuf_Timestamp& timestamp_proto);

  static core::Query DecodeQueryTarget(
      nanopb::Reader* reader,
      const google_firestore_v1_Target_QueryTarget& proto);

 private:
  std::unique_ptr<model::Document> DecodeFoundDocument(
      nanopb::Reader* reader,
      const google_firestore_v1_BatchGetDocumentsResponse& response) const;
  std::unique_ptr<model::NoDocument> DecodeMissingDocument(
      nanopb::Reader* reader,
      const google_firestore_v1_BatchGetDocumentsResponse& response) const;

  static void EncodeFieldsEntry(const model::ObjectValue::Map::value_type& kv,
                                uint32_t key_tag,
                                uint32_t value_tag);

  std::string EncodeQueryPath(const model::ResourcePath& path) const;

  const model::DatabaseId& database_id_;
  const std::string database_name_;
};

}  // namespace remote
}  // namespace firestore
}  // namespace firebase

#endif  // FIRESTORE_CORE_SRC_FIREBASE_FIRESTORE_REMOTE_SERIALIZER_H_
