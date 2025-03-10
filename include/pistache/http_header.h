/*
 * SPDX-FileCopyrightText: 2015 Mathieu Stefani
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/* http_header.h
   Mathieu Stefani, 19 August 2015

  Declaration of common http headers
*/

#pragma once

#include <memory>
#include <ostream>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

#include <pistache/http_defs.h>
#include <pistache/mime.h>
#include <pistache/net.h>

#define SAFE_HEADER_CAST

namespace Pistache::Http::Header
{

#ifdef SAFE_HEADER_CAST
    namespace detail
    {

        // compile-time FNV-1a hashing algorithm
        static constexpr uint64_t basis = 14695981039346656037ULL;
        static constexpr uint64_t prime = 1099511628211ULL;

        constexpr uint64_t hash_one(char c, const char* remain,
                                    unsigned long long value)
        {
            return c == 0 ? value : hash_one(remain[0], remain + 1, (value ^ c) * prime);
        }

        constexpr uint64_t hash(const char* str)
        {
            return hash_one(str[0], str + 1, basis);
        }

    } // namespace detail
#endif

#ifdef SAFE_HEADER_CAST
#define NAME(header_name)                                                               \
    static constexpr uint64_t Hash = Pistache::Http::Header::detail::hash(header_name); \
    uint64_t hash() const override { return Hash; }                                     \
    static constexpr const char* Name = header_name;                                    \
    const char* name() const override { return Name; }
#else
#define NAME(header_name)                            \
    static constexpr const char* Name = header_name; \
    const char* name() const override { return Name; }
#endif

    // 3.5 Content Codings
    // 3.6 Transfer Codings
    enum class Encoding { Gzip,
                          Br,
                          Compress,
                          Deflate,
                          Zstd,
                          Identity,
                          Chunked,
                          Unknown };

    /* Returns a textual representation of a given encoding */
    const char* encodingString(Encoding encoding);

    /* Returns the encoding corresponding to the given string */
    Encoding encodingFromString(std::string_view str);

    /* Returns true if the given encoding is supported by Pistache */
    bool encodingSupported(Encoding encoding);

    class Header
    {
    public:
        virtual ~Header()                = default;
        virtual const char* name() const = 0;

        virtual void parse(const std::string& data);
        virtual void parseRaw(const char* str, size_t len);

        virtual void write(std::ostream& stream) const = 0;

#ifdef SAFE_HEADER_CAST
        virtual uint64_t hash() const = 0;
#endif
    };

    template <typename H>
    struct IsHeader
    {

        template <typename T>
        static std::true_type test(decltype(T::Name)*);

        template <typename T>
        static std::false_type test(...);

        static constexpr bool value = std::is_base_of<Header, H>::value && std::is_same<decltype(test<H>(nullptr)), std::true_type>::value;
    };

#ifdef SAFE_HEADER_CAST
    template <typename To>
    typename std::enable_if<IsHeader<To>::value, std::shared_ptr<To>>::type
    header_cast(const std::shared_ptr<Header>& from)
    {
        return static_cast<To*>(0)->Hash == from->hash()
            ? std::static_pointer_cast<To>(from)
            : nullptr;
    }

    template <typename To>
    typename std::enable_if<IsHeader<To>::value, std::shared_ptr<const To>>::type
    header_cast(const std::shared_ptr<const Header>& from)
    {
        return static_cast<To*>(0)->Hash == from->hash()
            ? std::static_pointer_cast<const To>(from)
            : nullptr;
    }
#endif

    class Allow : public Header
    {
    public:
        NAME("Allow");

        Allow()
            : methods_()
        { }

        explicit Allow(const std::vector<Http::Method>& methods)
            : methods_(methods)
        { }
        explicit Allow(std::initializer_list<Http::Method> methods)
            : methods_(methods)
        { }

        explicit Allow(Http::Method method)
            : methods_()
        {
            methods_.push_back(method);
        }

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        void addMethod(Http::Method method);
        void addMethods(std::initializer_list<Method> methods);
        void addMethods(const std::vector<Http::Method>& methods);

        std::vector<Http::Method> methods() const { return methods_; }

    private:
        std::vector<Http::Method> methods_;
    };

    class Accept : public Header
    {
    public:
        NAME("Accept")

        Accept()
            : mediaRange_()
        { }

        explicit Accept(const std::vector<Mime::MediaType>& mediaRange)
            : mediaRange_(mediaRange)
        { }

        explicit Accept(std::initializer_list<Mime::MediaType> mediaRange)
            : mediaRange_(mediaRange)
        { }

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        const std::vector<Mime::MediaType> media() const { return mediaRange_; }

    private:
        std::vector<Mime::MediaType> mediaRange_;
    };

    class AccessControlAllowOrigin : public Header
    {
    public:
        NAME("Access-Control-Allow-Origin")

        AccessControlAllowOrigin()
            : uri_()
        { }

        explicit AccessControlAllowOrigin(const char* uri)
            : uri_(uri)
        { }
        explicit AccessControlAllowOrigin(const std::string& uri)
            : uri_(uri)
        { }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        void setUri(std::string uri) { uri_ = std::move(uri); }

        std::string uri() const { return uri_; }

    private:
        std::string uri_;
    };

    class AccessControlAllowHeaders : public Header
    {
    public:
        NAME("Access-Control-Allow-Headers")

        AccessControlAllowHeaders()
            : val_()
        { }

        explicit AccessControlAllowHeaders(const char* val)
            : val_(val)
        { }
        explicit AccessControlAllowHeaders(const std::string& val)
            : val_(val)
        { }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        void setUri(std::string val) { val_ = std::move(val); }

        std::string val() const { return val_; }

    private:
        std::string val_;
    };

    class AccessControlExposeHeaders : public Header
    {
    public:
        NAME("Access-Control-Expose-Headers")

        AccessControlExposeHeaders()
            : val_()
        { }

        explicit AccessControlExposeHeaders(const char* val)
            : val_(val)
        { }
        explicit AccessControlExposeHeaders(const std::string& val)
            : val_(val)
        { }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        void setUri(std::string val) { val_ = std::move(val); }

        std::string val() const { return val_; }

    private:
        std::string val_;
    };

    class AccessControlAllowMethods : public Header
    {
    public:
        NAME("Access-Control-Allow-Methods")

        AccessControlAllowMethods()
            : val_()
        { }

        explicit AccessControlAllowMethods(const char* val)
            : val_(val)
        { }
        explicit AccessControlAllowMethods(const std::string& val)
            : val_(val)
        { }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        void setUri(std::string val) { val_ = std::move(val); }

        std::string val() const { return val_; }

    private:
        std::string val_;
    };

    class CacheControl : public Header
    {
    public:
        NAME("Cache-Control")

        CacheControl()
            : directives_()
        { }

        explicit CacheControl(const std::vector<Http::CacheDirective>& directives)
            : directives_(directives)
        { }
        explicit CacheControl(Http::CacheDirective directive);
        explicit CacheControl(Http::CacheDirective::Directive directive)
            : CacheControl(Http::CacheDirective(directive))
        { }

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        std::vector<Http::CacheDirective> directives() const { return directives_; }

        void addDirective(Http::CacheDirective directive);
        void addDirective(Http::CacheDirective::Directive directive)
        {
            addDirective(Http::CacheDirective(directive));
        }
        void addDirectives(const std::vector<Http::CacheDirective>& directives);

    private:
        std::vector<Http::CacheDirective> directives_;
    };

    class Connection : public Header
    {
    public:
        NAME("Connection")

        Connection()
            : control_(ConnectionControl::KeepAlive)
        { }

        explicit Connection(ConnectionControl control)
            : control_(control)
        { }

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        ConnectionControl control() const { return control_; }

    private:
        ConnectionControl control_;
    };

    class EncodingHeader : public Header
    {
    public:
        EncodingHeader()
            : encoding_()
        { }

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        Encoding encoding() const { return encoding_; }

    protected:
        explicit EncodingHeader(Encoding encoding)
            : encoding_(encoding)
        { }

    private:
        Encoding encoding_;
    };

    class AcceptEncoding : public Header
    {
    public:
        NAME("Accept-Encoding")

        AcceptEncoding() = default;
        explicit AcceptEncoding(Encoding encoding);

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        const std::vector<std::pair<Encoding, float>>& encodings() const;

    private:
        /* Contains the encodings listed in the header, sorted by preference */
        std::vector<std::pair<Encoding, float>> encodings_;

        /*
         * Inserts a new element into the encodings_ vector, keeping it sorted
         * by qvalue
         */
        void insertEncoding(const std::pair<Encoding, float>& elem);
    };

    class ContentEncoding : public EncodingHeader
    {
    public:
        NAME("Content-Encoding")

        ContentEncoding()
            : EncodingHeader(Encoding::Identity)
        { }

        explicit ContentEncoding(Encoding encoding)
            : EncodingHeader(encoding)
        { }
    };

    class TransferEncoding : public EncodingHeader
    {
    public:
        NAME("Transfer-Encoding")

        TransferEncoding()
            : EncodingHeader(Encoding::Identity)
        { }

        explicit TransferEncoding(Encoding encoding)
            : EncodingHeader(encoding)
        { }
    };

    class ContentLength : public Header
    {
    public:
        NAME("Content-Length");

        ContentLength()
            : value_(0)
        { }

        explicit ContentLength(uint64_t val)
            : value_(val)
        { }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        uint64_t value() const { return value_; }

    private:
        uint64_t value_;
    };

    class Authorization : public Header
    {
    public:
        NAME("Authorization");

        enum class Method { Basic,
                            Bearer,
                            Unknown };

        Authorization()
            : value_("NONE")
        { }

        explicit Authorization(std::string&& val)
            : value_(std::move(val))
        { }
        explicit Authorization(const std::string& val)
            : value_(val)
        { }

        // What type of authorization method was used?
        Method getMethod() const noexcept;

        // Check if a particular authorization method was used...
        template <Method M>
        bool hasMethod() const noexcept { return hasMethod<M>(); }

        // Get decoded user ID and password if basic method was used...
        std::string getBasicUser() const;
        std::string getBasicPassword() const;

        // Set encoded user ID and password for basic method...
        void setBasicUserPassword(const std::string& User,
                                  const std::string& Password);

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        std::string value() const { return value_; }

    private:
        std::string value_;
    };

    template <>
    bool Authorization::hasMethod<Authorization::Method::Basic>() const noexcept;

    template <>
    bool Authorization::hasMethod<Authorization::Method::Bearer>() const noexcept;

    class ContentType : public Header
    {
    public:
        NAME("Content-Type")

        ContentType()
            : mime_()
        { }

        explicit ContentType(const Mime::MediaType& mime)
            : mime_(mime)
        { }
        explicit ContentType(std::string&& raw_mime_str)
            : ContentType(Mime::MediaType(std::move(raw_mime_str)))
        { }
        explicit ContentType(const std::string& raw_mime_str)
            : ContentType(Mime::MediaType(raw_mime_str))
        { }

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        Mime::MediaType mime() const { return mime_; }
        void setMime(const Mime::MediaType& mime) { mime_ = mime; }

    private:
        Mime::MediaType mime_;
    };

    class Date : public Header
    {
    public:
        NAME("Date")

        Date()
            : fullDate_()
        { }

        explicit Date(const FullDate& date)
            : fullDate_(date)
        { }

        void parse(const std::string& str) override;
        void write(std::ostream& os) const override;

        FullDate fullDate() const { return fullDate_; }

    private:
        FullDate fullDate_;
    };

    /**
     * @brief Represents an HTTP ETag (Entity Tag) with an optional weak validator.
     *
     * ETags are used for web caching and conditional requests. They help determine
     * whether a resource has changed. For more details, see:
     * [RFC 9110 - HTTP Semantics](https://datatracker.ietf.org/doc/html/rfc9110#section-8.8.3).
     */
    class ETag : public Header
    {
    public:
        NAME("ETag")

        ETag()
            : etagc_()
            , isWeak_(false)
        { }

        /**
         * @brief Construct a new ETag object
         *
         * @param etagc The ETag value. Must be only ETag value itself without quotes and weak validator flag.
         * @param useWeakValidator  Set to true if the ETag is weak (default: false).
         */
        explicit ETag(const std::string_view etagc, bool useWeakValidator = false)
            : etagc_(etagc)
            , isWeak_(useWeakValidator)
        {
            validateEtagcWithException(etagc);
        }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        /**
         * @brief check if etagc value is valid according to the RFC 9110
         *
         * @param etagc etagc value to check
         * @return true when etagc is a valid value
         * @return false otherwise
         */
        static bool isValidEtagc(std::string_view etagc);

        std::string etagc() const { return etagc_; }
        bool isWeak() const { return isWeak_; }

    private:
        std::string etagc_;
        bool isWeak_;

        /**
         * @brief check if etagc value is valid according to the RFC 9110
         *
         * @param etagc etagc value to check
         * @throw std::runtime_error if etagc value is not valid
         */
        static void validateEtagcWithException(std::string_view etagc);

        static constexpr std::string_view weakValidatorMark_ { "W/" };
    };

    class Expect : public Header
    {
    public:
        NAME("Expect")

        Expect()
            : expectation_()
        { }

        explicit Expect(Http::Expectation expectation)
            : expectation_(expectation)
        { }

        void parseRaw(const char* str, size_t len) override;
        void write(std::ostream& os) const override;

        Http::Expectation expectation() const { return expectation_; }

    private:
        Expectation expectation_;
    };

    class Host : public Header
    {
    public:
        NAME("Host");

        Host()
            : uriHost_()
            , port_(0)
        { }

        explicit Host(const std::string& data);
        explicit Host(const std::string& host, Port port);

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        std::string host() const { return uriHost_; }
        Port port() const { return port_; }

    private:
        std::string uriHost_;
        Port port_;
    };

    class LastModified : public Header
    {
    public:
        NAME("Last-Modified");

        LastModified()
            : fullDate_()
        { }

        explicit LastModified(const FullDate& fullDate)
            : fullDate_(fullDate)
        { }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        FullDate fullDate() const { return fullDate_; }

    private:
        FullDate fullDate_;
    };

    class Location : public Header
    {
    public:
        NAME("Location")

        Location()
            : location_()
        { }

        explicit Location(const std::string& location);

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        std::string location() const { return location_; }

    private:
        std::string location_;
    };

    class Server : public Header
    {
    public:
        NAME("Server")

        Server()
            : tokens_()
        { }

        explicit Server(const std::vector<std::string>& tokens);
        explicit Server(const std::string& token);
        explicit Server(const char* token);

        void parse(const std::string& token) override;
        void write(std::ostream& os) const override;

        std::vector<std::string> tokens() const { return tokens_; }

    private:
        std::vector<std::string> tokens_;
    };

    class UserAgent : public Header
    {
    public:
        NAME("User-Agent")

        UserAgent()
            : ua_()
        { }

        explicit UserAgent(const char* ua)
            : ua_(ua)
        { }

        explicit UserAgent(const std::string& ua)
            : ua_(ua)
        { }

        void parse(const std::string& data) override;
        void write(std::ostream& os) const override;

        void setAgent(std::string ua) { ua_ = std::move(ua); }

        std::string agent() const { return ua_; }

    private:
        std::string ua_;
    };

#define PISTACHE_CUSTOM_HEADER(header_class, header_name)                           \
    class header_class : public Pistache::Http::Header::Header                      \
    {                                                                               \
    public:                                                                         \
        NAME(header_name)                                                           \
                                                                                    \
        header_class() = default;                                                   \
                                                                                    \
        explicit header_class(const char* value)                                    \
            : value_ { value }                                                      \
        { }                                                                         \
                                                                                    \
        explicit header_class(std::string value)                                    \
            : value_(std::move(value))                                              \
        { }                                                                         \
                                                                                    \
        void parseRaw(const char* str, size_t len) final { value_ = { str, len }; } \
                                                                                    \
        void write(std::ostream& os) const final { os << value_; };                 \
                                                                                    \
        std::string val() const { return value_; };                                 \
                                                                                    \
    private:                                                                        \
        std::string value_;                                                         \
    };

#define CUSTOM_HEADER(header_name) PISTACHE_CUSTOM_HEADER(header_name, #header_name)

    class Raw
    {
    public:
        Raw();
        Raw(std::string name, std::string value)
            : name_(std::move(name))
            , value_(std::move(value))
        { }

        Raw(const Raw& other)            = default;
        Raw& operator=(const Raw& other) = default;

        Raw(Raw&& other)            = default;
        Raw& operator=(Raw&& other) = default;

        std::string name() const { return name_; }
        std::string value() const { return value_; }

    private:
        std::string name_;
        std::string value_;
    };

} // namespace Pistache::Http::Header
