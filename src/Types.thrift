/*
 * Copyright 2007-2012 Evernote Corporation.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * This file contains the definitions of the Evernote data model as it
 * is represented through the EDAM protocol.  This is the "client-independent"
 * view of the contents of a user's account.  Each client will translate the
 * neutral data model into an appropriate form for storage on that client.
 */

include "Limits.thrift"

namespace as3 com.evernote.edam.type
namespace java com.evernote.edam.type
namespace csharp Evernote.EDAM.Type
namespace py evernote.edam.type
namespace cpp evernote.edam
namespace rb Evernote.EDAM.Type
namespace php EDAM.Types
namespace cocoa EDAM
namespace perl EDAMTypes


// =============================== typedefs ====================================

/**
 * Every Evernote account is assigned a unique numeric identifier which
 * will not change for the life of the account.  This is independent of
 * the (string-based) "username" which is known by the user for login
 * purposes.  The user should have no reason to know their UserID.
 */
typedef i32 UserID


/**
 * Most data elements within a user's account (e.g. notebooks, notes, tags,
 * resources, etc.) are internally referred to using a globally unique
 * identifier that is written in a standard string format.  For example:
 *
 *    "8743428c-ef91-4d05-9e7c-4a2e856e813a"
 *
 * The internal components of the GUID are not given any particular meaning:
 * only the entire string is relevant as a unique identifier.
 */
typedef string Guid


/**
 * An Evernote Timestamp is the date and time of an event in UTC time.
 * This is expressed as a specific number of milliseconds since the
 * standard base "epoch" of:
 *
 *    January 1, 1970, 00:00:00 GMT
 *
 * NOTE:  the time is expressed at the resolution of milliseconds, but
 * the value is only precise to the level of seconds.   This means that
 * the last three (decimal) digits of the timestamp will be '000'.
 *
 * The Thrift IDL specification does not include a native date/time type,
 * so this value is used instead.
 *
 * The service will accept timestamp values (e.g. for Note created and update
 * times) between 1000-01-01 and 9999-12-31
 */
typedef i64 Timestamp

// ============================= Enumerations ==================================

/**
 * This enumeration defines the possible permission levels for a user.
 * Free accounts will have a level of NORMAL and paid Premium accounts
 * will have a level of PREMIUM.
 */
enum PrivilegeLevel {
  NORMAL = 1,
  PREMIUM = 3,
  MANAGER = 7,
  SUPPORT = 8,
  ADMIN = 9
}

/**
 * Every search query is specified as a sequence of characters.
 * Currently, only the USER query format is supported.
 */
enum QueryFormat {
  USER = 1,
  SEXP = 2
}


/**
 * This enumeration defines the possible sort ordering for notes when
 * they are returned from a search result.
 */
enum NoteSortOrder {
  CREATED = 1,
  UPDATED = 2,
  RELEVANCE = 3,
  UPDATE_SEQUENCE_NUMBER = 4,
  TITLE = 5
}


/**
 * This enumeration defines the possible states of a premium account
 *
 * NONE:    the user has never attempted to become a premium subscriber
 *
 * PENDING: the user has requested a premium account but their charge has not
 *   been confirmed
 *
 * ACTIVE:  the user has been charged and their premium account is in good
 *  standing
 *
 * FAILED:  the system attempted to charge the was denied. Their premium
 *   privileges have been revoked. We will periodically attempt to re-validate
 *   their order.
 *
 * CANCELLATION_PENDING: the user has requested that no further charges be made
 *   but the current account is still active.
 *
 * CANCELED: the premium account was canceled either because of failure to pay
 *   or user cancelation. No more attempts will be made to activate the account.
 */
enum PremiumOrderStatus {
  NONE                 = 0,
  PENDING              = 1,
  ACTIVE               = 2,
  FAILED               = 3,
  CANCELLATION_PENDING = 4,
  CANCELED             = 5
}

/**
 * Privilege levels for accessing shared notebooks.
 *
 * READ_NOTEBOOK: Recipient is able to read the contents of the shared notebook
 *   but does to have access to information about other recipients of the
 *   notebook or the activity stream information.
 *
 * MODIFY_NOTEBOOK_PLUS_ACTIVITY: Recipient has rights to read and modify the contents
 *   of the shared notebook, including the right to move notes to the trash and to create
 *   notes in the notebook.  The recipient can also access information about other
 *   recipients and the activity stream.
 *
 * READ_NOTEBOOK_PLUS_ACTIVITY: Recipient has READ_NOTEBOOK rights and can also
 *   access information about other recipients and the activity stream.
 *
 * GROUP: If the user belongs to a group, such as a Business, that has a defined
 *   privilege level, use the privilege level of the group as the privilege for
 *   the individual.
 *
 * FULL_ACCESS: Recipient has full rights to the shared notebook and recipient lists,
 *   including privilege to revoke and create invitations and to change privilege
 *   levels on invitations for individuals.  This privilege level is primarily intended
 *   for use by individual shares.
 *
 * BUSINESS_FULL_ACCESS: Intended for use with Business Notebooks, a
 * BUSINESS_FULL_ACCESS level is FULL_ACCESS with the additional rights to
 * change how the notebook will appear in the business library, including the
 * rights to publish and unpublish the notebook from the library.
 */
enum SharedNotebookPrivilegeLevel {
  READ_NOTEBOOK                  = 0,
  MODIFY_NOTEBOOK_PLUS_ACTIVITY  = 1,
  READ_NOTEBOOK_PLUS_ACTIVITY    = 2,
  GROUP                          = 3,
  FULL_ACCESS                    = 4,
  BUSINESS_FULL_ACCESS           = 5
}

/**
 * Enumeration of the roles that a User can have within a sponsored group.
 *
 * GROUP_MEMBER: The user is a member of the group with no special privileges.
 *
 * GROUP_ADMIN: The user is an administrator within the group.
 *
 * GROUP_OWNER: The user is the owner of the group.
 */
enum SponsoredGroupRole {
  GROUP_MEMBER = 1,
  GROUP_ADMIN = 2,
  GROUP_OWNER = 3
}

/**
 * Enumeration of the roles that a User can have within an Evernote Business account.
 * 
 * ADMIN: The user is an administrator of the Evernote Business account.
 * 
 * NORMAL: The user is a regular user within the Evernote Business account.
 */
enum BusinessUserRole {
  ADMIN = 1,
  NORMAL = 2,
}

/**
 * An enumeration describing restrictions on the domain of shared notebook
 * instances that are valid for a given operation, as used, for example, in
 * NotebookRestrictions.
 *
 * ONLY_JOINED_OR_PREVIEW: The domain consists of shared notebooks that
 *   "belong" to the recipient or still available for preview by any recipient.
 *   Shared notebooks that the recipient has joined (the username has already been
 *   assigned to our user) are in the domain.  Additionally, shared notebooks
 *   that allow preview and have not yet been joined are in the domain.
 * 
 * NO_SHARED_NOTEBOOKS: No shared notebooks are applicable to the operation.
 */
enum SharedNotebookInstanceRestrictions {
  ONLY_JOINED_OR_PREVIEW = 1,                           
  NO_SHARED_NOTEBOOKS    = 2   // most restrictive
}

// ============================== Constants ===================================

/**
 * A value for the "recipe" key in the "classifications" map in NoteAttributes
 * that indicates the user has classified a note as being a non-recipe.
 */
const string CLASSIFICATION_RECIPE_USER_NON_RECIPE = "000";

/**
 * A value for the "recipe" key in the "classifications" map in NoteAttributes
 * that indicates the user has classified a note as being a recipe.
 */
const string CLASSIFICATION_RECIPE_USER_RECIPE = "001";

/**
 * A value for the "recipe" key in the "classifications" map in NoteAttributes
 * that indicates the Evernote service has classified a note as being a recipe.
 */
const string CLASSIFICATION_RECIPE_SERVICE_RECIPE = "002";

/**
 * Standardized value for the 'source' NoteAttribute for notes that
 * were clipped from the web in some manner.
 */
const string EDAM_NOTE_SOURCE_WEB_CLIP = "web.clip";

/**
 * Standardized value for the 'source' NoteAttribute for notes that
 * were clipped from an email message.
 */
const string EDAM_NOTE_SOURCE_MAIL_CLIP = "mail.clip";

/**
 * Standardized value for the 'source' NoteAttribute for notes that
 * were created via email sent to Evernote's email interface.
 */
const string EDAM_NOTE_SOURCE_MAIL_SMTP_GATEWAY = "mail.smtp";


// ============================== Structures ===================================

/**
 * In several places, EDAM exchanges blocks of bytes of data for a component
 * which may be relatively large.  For example:  the contents of a clipped
 * HTML note, the bytes of an embedded image, or the recognition XML for
 * a large image.  This structure is used in the protocol to represent
 * any of those large blocks of data when they are transmitted or when
 * they are only referenced their metadata.
 *
 *<dl>
 * <dt>bodyHash</dt>
 *   <dd>This field carries a one-way hash of the contents of the
 *   data body, in binary form.  The hash function is MD5<br/>
 *   Length:  EDAM_HASH_LEN (exactly)
 *   </dd>
 *
 * <dt>size</dt>
 *   <dd>The length, in bytes, of the data body.
 *   </dd>
 *
 * <dt>body</dt>
 *   <dd>This field is set to contain the binary contents of the data
 *   whenever the resource is being transferred.  If only metadata is
 *   being exchanged, this field will be empty.  For example, a client could
 *   notify the service about the change to an attribute for a resource
 *   without transmitting the binary resource contents.
 *   </dd>
 * </dl>
 */
struct Data {
  1:  optional  binary bodyHash,
  2:  optional  i32 size,
  3:  optional  binary body
}


/**
 * A structure holding the optional attributes that can be stored
 * on a User.  These are generally less critical than the core User fields.
 *
 *<dl>
 * <dt>defaultLocationName</dt>
 *   <dd>the location string that should be associated
 *   with the user in order to determine where notes are taken if not otherwise
 *   specified.<br/>
 *   Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>defaultLatitude</dt>
 *   <dd>if set, this is the latitude that should be
 *   assigned to any notes that have no other latitude information.
 *   </dd>
 *
 * <dt>defaultLongitude</dt>
 *   <dd>if set, this is the longitude that should be
 *   assigned to any notes that have no other longitude information.
 *   </dd>
 *
 * <dt>preactivation</dt>
 *   <dd>if set, the user account is not yet confirmed for
 *   login.  I.e. the account has been created, but we are still waiting for
 *   the user to complete the activation step.
 *   </dd>
 *
 * <dt>viewedPromotions</dt>
 *   <dd>a list of promotions the user has seen.
 *    This list may occasionally be modified by the system when promotions are
 *    no longer available.<br/>
 *    Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>incomingEmailAddress</dt>
 *   <dd>if set, this is the email address that the
 *    user may send email to in order to add an email note directly into the
 *    account via the SMTP email gateway.  This is the part of the email
 *    address before the '@' symbol ... our domain is not included.
 *    If this is not set, the user may not add notes via the gateway.<br/>
 *    Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>recentMailedAddresses</dt>
 *   <dd>if set, this will contain a list of email
 *    addresses that have recently been used as recipients
 *    of outbound emails by the user.  This can be used to pre-populate a
 *    list of possible destinations when a user wishes to send a note via
 *    email.<br/>
 *    Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX each<br/>
 *    Max:  EDAM_USER_RECENT_MAILED_ADDRESSES_MAX entries
 *   </dd>
 *
 * <dt>comments</dt>
 *   <dd>Free-form text field that may hold general support
 *    information, etc.<br/>
 *    Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>dateAgreedToTermsOfService</dt>
 *   <dd>The date/time when the user agreed to
 *    the terms of service.  This can be used as the effective "start date"
 *    for the account.
 *   </dd>
 *
 * <dt>maxReferrals</dt>
 *   <dd>The number of referrals that the user is permitted
 *    to make.
 *   </dd>
 *
 * <dt>referralCount</dt>
 *   <dd>The number of referrals sent from this account.
 *   </dd>
 *
 * <dt>refererCode</dt>
 *   <dd>A code indicating where the user was sent from. AKA
 *    promotion code
 *   </dd>
 *
 * <dt>sentEmailDate</dt>
 *   <dd>The most recent date when the user sent outbound
 *    emails from the service.  Used with sentEmailCount to limit the number
 *    of emails that can be sent per day.
 *   </dd>
 *
 * <dt>sentEmailCount</dt>
 *   <dd>The number of emails that were sent from the user
 *    via the service on sentEmailDate.  Used to enforce a limit on the number
 *    of emails per user per day to prevent spamming.
 *   </dd>
 *
 * <dt>dailyEmailLimit</dt>
 *   <dd>If set, this is the maximum number of emails that
 *    may be sent in a given day from this account.  If unset, the server will
 *    use the configured default limit.
 *   </dd>
 *
 * <dt>emailOptOutDate</dt>
 *   <dd>If set, this is the date when the user asked
 *    to be excluded from offers and promotions sent by Evernote.  If not set,
 *    then the user currently agrees to receive these messages.
 *   </dd>
 *
 * <dt>partnerEmailOptInDate</dt>
 *   <dd>If set, this is the date when the user asked
 *    to be included in offers and promotions sent by Evernote's partners.
 *    If not sent, then the user currently does not agree to receive these
 *    emails.
 *   </dd>
 *
 * <dt>preferredLanguage</dt>
 *   <dd>a 2 character language codes based on:
 *       http://ftp.ics.uci.edu/pub/ietf/http/related/iso639.txt used for
 *      localization purposes to determine what language to use for the web
 *      interface and for other direct communication (e.g. emails).
 *   </dd>
 *
 * <dt>preferredCountry</dt>
 *   <dd>Preferred country code based on ISO 3166-1-alpha-2 indicating the
 *   users preferred country</dd>
 *
 * <dt>clipFullPage</dt>
 *   <dd>Boolean flag set to true if the user wants to clip full pages by
 *   default when they use the web clipper without a selection.</dd>
 *
 * <dt>twitterUserName</dt>
 *   <dd>The username of the account of someone who has chosen to enable
 *   Twittering into Evernote.  This value is subject to change, since users
 *   may change their Twitter user name.</dd>
 *
 * <dt>twitterId</dt>
 *   <dd>The unique identifier of the user's Twitter account if that user
 *   has chosen to enable Twittering into Evernote.</dd>
 *
 * <dt>groupName</dt>
 *   <dd>A name identifier used to identify a particular set of branding and
 *    light customization.</dd>
 *
 * <dt>recognitionLanguage</dt>
 *   <dd>a 2 character language codes based on:
 *       http://ftp.ics.uci.edu/pub/ietf/http/related/iso639.txt
 *       If set, this is used to determine the language that should be used
 *       when processing images and PDF files to find text.
 *       If not set, then the 'preferredLanguage' will be used.
 *   </dd>
 *
 * <dt>customerProfileId</dt>
 *   <dd>a numeric identified which provides a linkage between the user record
 *       and the direct credit card payment creditcard profile.
 *   </dd>
 *
 * <dt>educationalInstitution</dt>
 *   <dd>a flag indicating that the user is part of an educational institution which
 *   makes them eligible for discounts on bulk purchases
 *   </dd>
 *
 * <dt>businessAddress</dt>
 *   <dd>A string recording the business address of a Sponsored Account user who has requested invoicing.
 *   </dd>
 * </dl>
 *
 * <dt>hideSponsorBilling</dt>
 *   <dd>A flag indicating whether to hide the billing information on a sponsored
 *       account owner's settings page
 *   </dd>
 * </dl>
 *
 * <dt>taxExempt</dt>
 *   <dd>A flag indicating the user's sponsored group is exempt from sale tax
 *   </dd>
 * </dl>
 */
struct UserAttributes {
  1:  optional  string defaultLocationName,
  2:  optional  double defaultLatitude,
  3:  optional  double defaultLongitude,
  4:  optional  bool preactivation,
  5:  optional  list<string> viewedPromotions,
  6:  optional  string incomingEmailAddress,
  7:  optional  list<string> recentMailedAddresses,
  9:  optional  string comments,
  11: optional  Timestamp dateAgreedToTermsOfService,
  12: optional  i32 maxReferrals,
  13: optional  i32 referralCount,
  14: optional  string refererCode,
  15: optional  Timestamp sentEmailDate,
  16: optional  i32 sentEmailCount,
  17: optional  i32 dailyEmailLimit,
  18: optional  Timestamp emailOptOutDate,
  19: optional  Timestamp partnerEmailOptInDate,
  20: optional  string preferredLanguage,
  21: optional  string preferredCountry,
  22: optional  bool clipFullPage,
  23: optional  string twitterUserName,
  24: optional  string twitterId,
  25: optional  string groupName,
  26: optional  string recognitionLanguage,
  27: optional  i64 customerProfileId,
  28: optional  string referralProof,
  29: optional  bool educationalDiscount,
  30: optional  string businessAddress,
  31: optional  bool hideSponsorBilling,
  32: optional  bool taxExempt
}

/**
 * This represents the bookkeeping information for the user's subscription.
 *
 *<dl>
 * <dt>uploadLimit</dt>
 *   <dd>The number of bytes that can be uploaded to the account
 *   in the current month.  For new notes that are created, this is the length
 *   of the note content (in Unicode characters) plus the size of each resource
 *   (in bytes).  For edited notes, this is the the difference between the old
 *   length and the new length (if this is greater than 0) plus the size of
 *   each new resource.
 *   </dd>
 * <dt>uploadLimitEnd</dt>
 *   <dd>The date and time when the current upload limit
 *   expires.  At this time, the monthly upload count reverts to 0 and a new
 *   limit is imposed.  This date and time is exclusive, so this is effectively
 *   the start of the new month.
 *   </dd>
 * <dt>uploadLimitNextMonth</dt>
 *   <dd> When uploadLimitEnd is reached, the service
 *   will change uploadLimit to uploadLimitNextMonth. If a premium account is
 *   canceled, this mechanism will reset the quota appropriately.
 *   </dd>
 * <dt>premiumServiceStatus</dt>
 *   <dd>Indicates the phases of a premium account
 *   during the billing process.
 *   </dd>
 * <dt>premiumOrderNumber</dt>
 *   <dd>The order number used by the commerce system to
 *   process recurring payments
 *   </dd>
 * <dt>premiumServiceStart</dt>
 *   <dd>The start date when this premium promotion
 *   began (this number will get overwritten if a premium service is canceled
 *   and then re-activated).
 *   </dd>
 * <dt>premiumCommerceService</dt>
 *   <dd>The commerce system used (paypal, Google
 *   checkout, etc)
 *   </dd>
 * <dt>premiumServiceSKU</dt>
 *   <dd>The code associated with the purchase eg. monthly
 *   or annual purchase. Clients should interpret this value and localize it.
 *   </dd>
 * <dt>lastSuccessfulCharge</dt>
 *   <dd>Date the last time the user was charged.
 *   Null if never charged.
 *   </dd>
 * <dt>lastFailedCharge</dt>
 *   <dd>Date the last time a charge was attempted and
 *   failed.
 *   </dd>
 * <dt>lastFailedChargeReason</dt>
 *   <dd>Reason provided for the charge failure
 *   </dd>
 * <dt>nextPaymentDue</dt>
 *   <dd>The end of the billing cycle. This could be in the
 *   past if there are failed charges.
 *   </dd>
 * <dt>premiumLockUntil</dt>
 *   <dd>An internal variable to manage locking operations
 *   on the commerce variables.
 *   </dd>
 * <dt>updated</dt>
 *   <dd>The date any modification where made to this record.
 *   </dd>
 * <dt>premiumSubscriptionNumber</dt>
 *   <dd>The number number identifying the
 *   recurring subscription used to make the recurring charges.
 *   </dd>
 * <dt>lastRequestedCharge</dt>
 *   <dd>Date charge last attempted</dd>
 * <dt>currency</dt>
 *   <dd>ISO 4217 currency code</dd>
 * <dt>unitPrice</dt>
 *   <dd>charge in the smallest unit of the currency (e.g. cents for USD)</dd>
 * <dt>businessId</dt>
 *   <dd>If set, the ID of the Evernote Business account that the user is a
 *       member of. If not set, the user is not a member of a business.</dd>
 * <dt>businessName</dt>
 *   <dd>The human-readable name of the Evernote Business account that
 *       the user is a member of.</dd>
 * <dt>businessRole</dt>
 *   <dd>If set, the role of the user within the Evernote Business account
 *       that they are a member of.</dd>
 * </dl>
 */
struct Accounting {
  1:  optional  i64                uploadLimit,
  2:  optional  Timestamp          uploadLimitEnd,
  3:  optional  i64                uploadLimitNextMonth,
  4:  optional  PremiumOrderStatus premiumServiceStatus,
  5:  optional  string             premiumOrderNumber,
  6:  optional  string             premiumCommerceService,
  7:  optional  Timestamp          premiumServiceStart,
  8:  optional  string             premiumServiceSKU,
  9:  optional  Timestamp          lastSuccessfulCharge,
  10: optional  Timestamp          lastFailedCharge,
  11: optional  string             lastFailedChargeReason,
  12: optional  Timestamp          nextPaymentDue,
  13: optional  Timestamp          premiumLockUntil,
  14: optional  Timestamp          updated,
  16: optional  string             premiumSubscriptionNumber,
  17: optional  Timestamp          lastRequestedCharge,
  18: optional  string             currency,
  19: optional  i32                unitPrice,
  20: optional  i32                businessId,
  21: optional  string             businessName,
  22: optional  BusinessUserRole   businessRole
}


/**
 * This structure is used to provide information about a user's Premium account.
 *<dl>
 * <dt>currentTime</dt>
 *   <dd>
 *   The server-side date and time when this data was generated.
 *   </dd>
 * <dt>premium</dt>
 *   <dd>
 *   True if the user's account is Premium.
 *   </dd>
 * <dt>premiumRecurring</dt>
 *   <dd>
 *   True if the user's account is Premium and has a recurring payment method.
 *   </dd>
 * <dt>premiumExpirationDate</dt>
 *   <dd>
 *   The date when the user's Premium account expires, or the date when the
 *   user's account will be charged if it has a recurring payment method.
 *   </dd>
 * <dt>premiumExtendable</dt>
 *   <dd>
 *   True if the user is eligible for purchasing Premium account extensions.
 *   </dd>
 * <dt>premiumPending</dt>
 *   <dd>
 *   True if the user's Premium account is pending payment confirmation
 *   </dd>
 * <dt>premiumCancellationPending</dt>
 *   <dd>
 *   True if the user has requested that no further charges to be made; the
 *   Premium account will remain active until it expires.
 *   </dd>
 * <dt>canPurchaseUploadAllowance</dt>
 *   <dd>
 *   True if the user is eligible for purchasing additional upload allowance.
 *   </dd>
 * <dt>sponsoredGroupName</dt>
 *   <dd>
 *   The name of the sponsored group that the user is part of.
 *   </dd>
 * <dt>sponsoredGroupRole</dt>
 *   <dd>
 *   DEPRECATED - will be removed in a future update.
 *   </dd>
 * </dl>
 */
struct PremiumInfo {
  1:  required Timestamp currentTime,
  2:  required bool premium,
  3:  required bool premiumRecurring,
  4:  optional Timestamp premiumExpirationDate,
  5:  required bool premiumExtendable,
  6:  required bool premiumPending,
  7:  required bool premiumCancellationPending,
  8:  required bool canPurchaseUploadAllowance,
  9:  optional string sponsoredGroupName,
  10: optional SponsoredGroupRole sponsoredGroupRole
}


/**
 * This represents the information about a single user account.
 *<dl>
 * <dt>id</dt>
 *   <dd>The unique numeric identifier for the account, which will not
 *   change for the lifetime of the account.
 *   </dd>
 *
 * <dt>username</dt>
 *   <dd>The name that uniquely identifies a single user account. This name
 *   may be presented by the user, along with their password, to log into
 *   their account.
 *   May only contain a-z, 0-9, or '-', and may not start or end with the '-'
 *   <br/>
 *   Length:  EDAM_USER_USERNAME_LEN_MIN - EDAM_USER_USERNAME_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_USER_USERNAME_REGEX
 *   </dd>
 *
 * <dt>email</dt>
 *   <dd>The email address registered for the user.  Must comply with
 *   RFC 2821 and RFC 2822.<br/>
 *   For privacy reasons, this field may not be populated when a User
 *   is retrieved via a call to UserStore.getUser().
 *   Length:  EDAM_EMAIL_LEN_MIN - EDAM_EMAIL_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_EMAIL_REGEX
 *   </dd>
 *
 * <dt>name</dt>
 *   <dd>The printable name of the user, which may be a combination
 *   of given and family names.  This is used instead of separate "first"
 *   and "last" names due to variations in international name format/order.
 *   May not start or end with a whitespace character.  May contain any
 *   character but carriage return or newline (Unicode classes Zl and Zp).
 *   <br/>
 *   Length:  EDAM_USER_NAME_LEN_MIN - EDAM_USER_NAME_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_USER_NAME_REGEX
 *   </dd>
 *
 * <dt>timezone</dt>
 *   <dd>The zone ID for the user's default location.  If present,
 *   this may be used to localize the display of any timestamp for which no
 *   other timezone is available.
 *   The format must be encoded as a standard zone ID such as
 *   "America/Los_Angeles" or "GMT+08:00"
 *   <br/>
 *   Length:  EDAM_TIMEZONE_LEN_MIN - EDAM_TIMEZONE_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_TIMEZONE_REGEX
 *   </dd>
 *
 * <dt>privilege</dt>
 *   <dd>The level of access permitted for the user.
 *   </dd>
 *
 * <dt>created</dt>
 *   <dd>The date and time when this user account was created in the
 *   service.
 *   </dd>
 *
 * <dt>updated</dt>
 *   <dd>The date and time when this user account was last modified
 *   in the service.
 *   </dd>
 *
 * <dt>deleted</dt>
 *   <dd>If the account has been deleted from the system (e.g. as
 *   the result of a legal request by the user), the date and time of the
 *   deletion will be represented here.  If not, this value will not be set.
 *   </dd>
 *
 * <dt>active</dt>
 *   <dd>If the user account is available for login and
 *   synchronization, this flag will be set to true.
 *   </dd>
 *
 * <dt>shardId</dt>
 *   <dd>DEPRECATED - Client applications should have no need to use this field.
 *   </dd>
 *
 * <dt>attributes</dt>
 *   <dd>If present, this will contain a list of the attributes
 *   for this user account.
 *   </dd>
 *
 * <dt>accounting</dt>
 *   <dd>Bookkeeping information for the user's subscription.
 *   </dd>
 *
 * <dt>premiumInfo</dt>
 *   <dd>If present, this will contain a set of commerce information
 *   relating to the user's premium service level.
 *   </dd>
 * </dl>
 */
struct User {
  1:  optional  UserID id,
  2:  optional  string username,
  3:  optional  string email,
  4:  optional  string name,
  6:  optional  string timezone,
  7:  optional  PrivilegeLevel privilege,
  9:  optional  Timestamp created,
  10: optional  Timestamp updated,
  11: optional  Timestamp deleted,
  13: optional  bool active,
  14: optional  string shardId,
  15: optional  UserAttributes attributes,
  16: optional  Accounting accounting,
  17: optional  PremiumInfo premiumInfo
}


/**
 * A tag within a user's account is a unique name which may be organized
 * a simple hierarchy.
 *<dl>
 * <dt>guid</dt>
 *   <dd>The unique identifier of this tag. Will be set by the service,
 *   so may be omitted by the client when creating the Tag.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>name</dt>
 *   <dd>A sequence of characters representing the tag's identifier.
 *   Case is preserved, but is ignored for comparisons.
 *   This means that an account may only have one tag with a given name, via
 *   case-insensitive comparison, so an account may not have both "food" and
 *   "Food" tags.
 *   May not contain a comma (','), and may not begin or end with a space.
 *   <br/>
 *   Length:  EDAM_TAG_NAME_LEN_MIN - EDAM_TAG_NAME_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_TAG_NAME_REGEX
 *   </dd>
 *
 * <dt>parentGuid</dt>
 *   <dd>If this is set, then this is the GUID of the tag that
 *   holds this tag within the tag organizational hierarchy.  If this is
 *   not set, then the tag has no parent and it is a "top level" tag.
 *   Cycles are not allowed (e.g. a->parent->parent == a) and will be
 *   rejected by the service.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>updateSequenceNum</dt>
 *   <dd>A number identifying the last transaction to
 *   modify the state of this object.  The USN values are sequential within an
 *   account, and can be used to compare the order of modifications within the
 *   service.
 *   </dd>
 * </dl>
 */
struct Tag {
  1:  optional  Guid guid,
  2:  optional  string name,
  3:  optional  Guid parentGuid,
  4:  optional  i32 updateSequenceNum
}


/**
 * A structure that wraps a map of name/value pairs whose values are not
 * always present in the structure in order to reduce space when obtaining
 * batches of entities that contain the map.
 *
 * When the server provides the client with a LazyMap, it will fill in either
 * the keysOnly field or the fullMap field, but never both, based on the API
 * and parameters.
 *
 * When a client provides a LazyMap to the server as part of an update to
 * an object, the server will only update the LazyMap if the fullMap field is
 * set. If the fullMap field is not set, the server will not make any changes
 * to the map.
 *
 * Check the API documentation of the individual calls involving the LazyMap
 * for full details including the constraints of the names and values of the
 * map.
 *
 * <dl>
 * <dt>keysOnly</dt>
 *   <dd>The set of keys for the map.  This field is ignored by the
 *       server when set.
 *   </dd>
 *
 * <dt>fullMap</dt>
 *   <dd>The complete map, including all keys and values.
 *   </dd>
 * </dl>
 */
struct LazyMap {
  1:  optional  set<string> keysOnly,
  2:  optional  map<string, string> fullMap
}


/**
 * Structure holding the optional attributes of a Resource
 * <dl>
 * <dt>sourceURL</dt>
 *   <dd>the original location where the resource was hosted
 *   <br/>
 *    Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>timestamp</dt>
 *   <dd>the date and time that is associated with this resource
 *   (e.g. the time embedded in an image from a digital camera with a clock)
 *   </dd>
 *
 * <dt>latitude</dt>
 *   <dd>the latitude where the resource was captured
 *   </dd>
 *
 * <dt>longitude</dt>
 *   <dd>the longitude where the resource was captured
 *   </dd>
 *
 * <dt>altitude</dt>
 *   <dd>the altitude where the resource was captured
 *   </dd>
 *
 * <dt>cameraMake</dt>
 *   <dd>information about an image's camera, e.g. as embedded in
 *   the image's EXIF data
 *   <br/>
 *   Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>cameraModel</dt>
 *   <dd>information about an image's camera, e.g. as embedded
 *   in the image's EXIF data
 *   <br/>
 *   Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>clientWillIndex</dt>
 *   <dd>if true, then the original client that submitted
 *   the resource plans to submit the recognition index for this resource at a
 *   later time.
 *   </dd>
 *
 * <dt>recoType</dt>
 *   <dd>DEPRECATED - this field is no longer set by the service, so should
 *     be ignored.
 *   </dd>
 *
 * <dt>fileName</dt>
 *   <dd>if the resource came from a source that provided an
 *   explicit file name, the original name will be stored here.  Many resources
 *   come from unnamed sources, so this will not always be set.
 *   </dd>
 *
 * <dt>attachment</dt>
 *   <dd>this will be true if the resource should be displayed as an attachment,
 *   or false if the resource should be displayed inline (if possible).
 *   </dd>
 *
 * <dt>applicationData</dt>
 * <dd>Provides a location for applications to store a relatively small
 * (4kb) blob of data associated with a Resource that is not visible to the user
 * and that is opaque to the Evernote service. A single application may use at most
 * one entry in this map, using its API consumer key as the map key. See the
 * documentation for LazyMap for a description of when the actual map values
 * are returned by the service.
 * <p>To safely add or modify your application's entry in the map, use
 * NoteStore.setResourceApplicationDataEntry. To safely remove your application's
 * entry from the map, use NoteStore.unsetResourceApplicationDataEntry.</p>
 * Minimum length of a name (key): EDAM_APPLICATIONDATA_NAME_LEN_MIN
 * <br/>
 * Sum max size of key and value: EDAM_APPLICATIONDATA_ENTRY_LEN_MAX
 * <br/>
 * Syntax regex for name (key): EDAM_APPLICATIONDATA_NAME_REGEX
 * </dd>
 *
 * </dl>
 */
struct ResourceAttributes {
  1:  optional  string sourceURL,
  2:  optional  Timestamp timestamp,
  3:  optional  double latitude,
  4:  optional  double longitude,
  5:  optional  double altitude,
  6:  optional  string cameraMake,
  7:  optional  string cameraModel,
  8:  optional  bool clientWillIndex,
  9:  optional  string recoType,
  10: optional  string fileName,
  11: optional  bool attachment,
  12: optional  LazyMap applicationData
}


/**
 * Every media file that is embedded or attached to a note is represented
 * through a Resource entry.
 * <dl>
 * <dt>guid</dt>
 *   <dd>The unique identifier of this resource.  Will be set whenever
 *   a resource is retrieved from the service, but may be null when a client
 *   is creating a resource.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>noteGuid</dt>
 *   <dd>The unique identifier of the Note that holds this
 *   Resource. Will be set whenever the resource is retrieved from the service,
 *   but may be null when a client is creating a resource.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>data</dt>
 *   <dd>The contents of the resource.
 *   Maximum length:  The data.body is limited to EDAM_RESOURCE_SIZE_MAX_FREE
 *   for free accounts and EDAM_RESOURCE_SIZE_MAX_PREMIUM for premium accounts.
 *   </dd>
 *
 * <dt>mime</dt>
 *   <dd>The MIME type for the embedded resource.  E.g. "image/gif"
 *   <br/>
 *   Length:  EDAM_MIME_LEN_MIN - EDAM_MIME_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_MIME_REGEX
 *   </dd>
 *
 * <dt>width</dt>
 *   <dd>If set, this contains the display width of this resource, in
 *   pixels.
 *   </dd>
 *
 * <dt>height</dt>
 *   <dd>If set, this contains the display height of this resource,
 *   in pixels.
 *   </dd>
 *
 * <dt>duration</dt>
 *   <dd>DEPRECATED: ignored.
 *   </dd>
 *
 * <dt>active</dt>
 *   <dd>DEPRECATED: ignored.
 *   </dd>
 *
 * <dt>recognition</dt>
 *   <dd>If set, this will hold the encoded data that provides
 *   information on search and recognition within this resource.
 *   </dd>
 *
 * <dt>attributes</dt>
 *   <dd>A list of the attributes for this resource.
 *   </dd>
 *
 * <dt>updateSequenceNum</dt>
 *   <dd>A number identifying the last transaction to
 *   modify the state of this object. The USN values are sequential within an
 *   account, and can be used to compare the order of modifications within the
 *   service.
 *   </dd>
 *
 * <dt>alternateData</dt>
 *   <dd>Some Resources may be assigned an alternate data format by the service
 *   which may be more appropriate for indexing or rendering than the original
 *   data provided by the user.  In these cases, the alternate data form will
 *   be available via this Data element.  If a Resource has no alternate form,
 *   this field will be unset.</dd>
 * </dl>
 */
struct Resource {
  1:  optional  Guid guid,
  2:  optional  Guid noteGuid,
  3:  optional  Data data,
  4:  optional  string mime,
  5:  optional  i16 width,
  6:  optional  i16 height,
  7:  optional  i16 duration,
  8:  optional  bool active,
  9:  optional  Data recognition,
  11: optional  ResourceAttributes attributes,
  12: optional  i32 updateSequenceNum,
  13: optional  Data alternateData
}


/**
 * The list of optional attributes that can be stored on a note.
 * <dl>
 * <dt>subjectDate</dt>
 *   <dd>time that the note refers to
 *   </dd>
 *
 * <dt>latitude</dt>
 *   <dd>the latitude where the note was taken
 *   </dd>
 *
 * <dt>longitude</dt>
 *   <dd>the longitude where the note was taken
 *   </dd>
 *
 * <dt>altitude</dt>
 *   <dd>the altitude where the note was taken
 *   </dd>
 *
 * <dt>author</dt>
 *   <dd>the author of the content of the note
 *   <br/>
 *   Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>source</dt>
 *   <dd>the method that the note was added to the account, if the
 *   note wasn't directly authored in an Evernote desktop client.
 *   <br/>
 *   Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>sourceURL</dt>
 *   <dd>the original location where the resource was hosted. For web clips,
 *   this will be the URL of the page that was clipped.
 *   <br/>
 *   Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>sourceApplication</dt>
 *   <dd>an identifying string for the application that
 *   created this note.  This string does not have a guaranteed syntax or
 *   structure -- it is intended for human inspection and tracking.
 *   <br/>
 *   Length:  EDAM_ATTRIBUTE_LEN_MIN - EDAM_ATTRIBUTE_LEN_MAX
 *   </dd>
 *
 * <dt>shareDate</dt>
 *  <dd>The date and time when this note was directly shared via its own URL.
 *  This is only set on notes that were individually shared - it is independent
 *  of any notebook-level sharing of the containing notepbook. This field
 *  is treated as "read-only" for clients; the server will ignore changes
 *  to this field from an external client.
 *  </dd>
 *
 * <dt>placeName</dt>
 * <dd>Allows the user to assign a human-readable location name associated
 * with a note. Users may assign values like 'Home' and 'Work'. Place
 * names may also be populated with values from geonames database
 * (e.g., a restaurant name). Applications are encouraged to normalize values
 * so that grouping values by place name provides a useful result. Applications
 * MUST NOT automatically add place name values based on geolocation without
 * confirmation from the user; that is, the value in this field should be
 * more useful than a simple automated lookup based on the note's latitude
 * and longitude.</dd>
 *
 * <dt>contentClass</dt>
 * <dd>The class (or type) of note. This field is used to indicate to
 * clients that special structured information is represented within
 * the note such that special rules apply when making
 * modifications. If contentClass is set and the client
 * application does not specifically support the specified class,
 * the client MUST treat the note as read-only. In this case, the
 * client MAY modify the note's notebook and tags via the
 * Note.notebookGuid and Note.tagGuids fields.
 * <p>Applications should set contentClass only when they are creating notes
 * that contain structured information that needs to be maintained in order
 * for the user to be able to use the note within that application.
 * Setting contentClass makes a note read-only in other applications, so
 * there is a trade-off when an application chooses to use contentClass.
 * Applications that set contentClass when creating notes must use a contentClass
 * string of the form <i>CompanyName.ApplicationName</i> to ensure uniqueness.</p>
 * Length restrictions: EDAM_NOTE_CONTENT_CLASS_LEN_MIN, EDAM_NOTE_CONTENT_CLASS_LEN_MAX
 * <br/>
 * Regex: EDAM_NOTE_CONTENT_CLASS_REGEX
 * </dd>
 *
 * <dt>applicationData</dt>
 * <dd>Provides a location for applications to store a relatively small
 * (4kb) blob of data that is not meant to be visible to the user and
 * that is opaque to the Evernote service. A single application may use at most
 * one entry in this map, using its API consumer key as the map key. See the
 * documentation for LazyMap for a description of when the actual map values
 * are returned by the service.
 * <p>To safely add or modify your application's entry in the map, use
 * NoteStore.setNoteApplicationDataEntry. To safely remove your application's
 * entry from the map, use NoteStore.unsetNoteApplicationDataEntry.</p>
 * Minimum length of a name (key): EDAM_APPLICATIONDATA_NAME_LEN_MIN
 * <br/>
 * Sum max size of key and value: EDAM_APPLICATIONDATA_ENTRY_LEN_MAX
 * <br/>
 * Syntax regex for name (key): EDAM_APPLICATIONDATA_NAME_REGEX
 * </dd>
 *
 * <dt>lastEditedBy</dt>
 * <dd>An indication of who made the last change to the note.  If you are
 * accessing the note via a shared notebook to which you have modification
 * rights, or if you are the owner of the notebook to which the note belongs,
 * then you have access to the value.  In this case, the value will be
 * unset if the owner of the notebook containing the note was the last to
 * make the modification, else it will be a string describing the
 * guest who made the last edit.  If you do not have access to this value,
 * it will be left unset.  This field is read-only by clients.  The server
 * will ignore all values set by clients into this field.</dd>

 * <dt>classifications</dt>
 * <dd>A map of classifications applied to the note by clients or by the
 * Evernote service. The key is the string name of the classification type,
 * and the value is a constant that begins with CLASSIFICATION_.</dd>
 *
 * </dl>
 */
struct NoteAttributes {
  1:  optional  Timestamp subjectDate,
  10: optional  double latitude,
  11: optional  double longitude,
  12: optional  double altitude,
  13: optional  string author,
  14: optional  string source,
  15: optional  string sourceURL,
  16: optional  string sourceApplication,
  17: optional  Timestamp shareDate,
  21: optional  string placeName,
  22: optional  string contentClass,
  23: optional  LazyMap applicationData,
  24: optional  string lastEditedBy,
  26: optional  map<string, string> classifications
}


/**
 * Represents a single note in the user's account.
 *
 * <dl>
 * <dt>guid</dt>
 *   <dd>The unique identifier of this note.  Will be set by the
 *   server, but will be omitted by clients calling NoteStore.createNote()
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>title</dt>
 *   <dd>The subject of the note.  Can't begin or end with a space.
 *   <br/>
 *   Length:  EDAM_NOTE_TITLE_LEN_MIN - EDAM_NOTE_TITLE_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_NOTE_TITLE_REGEX
 *   </dd>
 *
 * <dt>content</dt>
 *   <dd>The XHTML block that makes up the note.  This is
 *   the canonical form of the note's contents, so will include abstract
 *   Evernote tags for internal resource references.  A client may create
 *   a separate transformed version of this content for internal presentation,
 *   but the same canonical bytes should be used for transmission and
 *   comparison unless the user chooses to modify their content.
 *   <br/>
 *   Length:  EDAM_NOTE_CONTENT_LEN_MIN - EDAM_NOTE_CONTENT_LEN_MAX
 *   </dd>
 *
 * <dt>contentHash</dt>
 *   <dd>The binary MD5 checksum of the UTF-8 encoded content
 *   body. This will always be set by the server, but clients may choose to omit
 *   this when they submit a note with content.
 *   <br/>
 *   Length:  EDAM_HASH_LEN (exactly)
 *   </dd>
 *
 * <dt>contentLength</dt>
 *   <dd>The number of Unicode characters in the content of
 *   the note.  This will always be set by the service, but clients may choose
 *   to omit this value when they submit a Note.
 *   </dd>
 *
 * <dt>created</dt>
 *   <dd>The date and time when the note was created in one of the
 *   clients.  In most cases, this will match the user's sense of when
 *   the note was created, and ordering between notes will be based on
 *   ordering of this field.  However, this is not a "reliable" timestamp
 *   if a client has an incorrect clock, so it cannot provide a true absolute
 *   ordering between notes.  Notes created directly through the service
 *   (e.g. via the web GUI) will have an absolutely ordered "created" value.
 *   </dd>
 *
 * <dt>updated</dt>
 *   <dd>The date and time when the note was last modified in one of
 *   the clients.  In most cases, this will match the user's sense of when
 *   the note was modified, but this field may not be absolutely reliable
 *   due to the possibility of client clock errors.
 *   </dd>
 *
 * <dt>deleted</dt>
 *   <dd>If present, the note is considered "deleted", and this
 *   stores the date and time when the note was deleted by one of the clients.
 *   In most cases, this will match the user's sense of when the note was
 *   deleted, but this field may be unreliable due to the possibility of
 *   client clock errors.
 *   </dd>
 *
 * <dt>active</dt>
 *   <dd>If the note is available for normal actions and viewing,
 *   this flag will be set to true.
 *   </dd>
 *
 * <dt>updateSequenceNum</dt>
 *   <dd>A number identifying the last transaction to
 *   modify the state of this note (including changes to the note's attributes
 *   or resources).  The USN values are sequential within an account,
 *   and can be used to compare the order of modifications within the service.
 *   </dd>
 *
 * <dt>notebookGuid</dt>
 *   <dd>The unique identifier of the notebook that contains
 *   this note.  If no notebookGuid is provided on a call to createNote(), the
 *   default notebook will be used instead.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>tagGuids</dt>
 *   <dd>A list of the GUID identifiers for tags that are applied to this note.
 *   This may be provided in a call to createNote() to unambiguously declare
 *   the tags that should be assigned to the new note.  Alternately, clients
 *   may pass the names of desired tags via the 'tagNames' field during
 *   note creation.
 *   If the list of tags are omitted on a call to createNote(), then
 *   the server will assume that no changes have been made to the resources.
 *   Maximum:  EDAM_NOTE_TAGS_MAX tags per note
 *   </dd>
 *
 * <dt>resources</dt>
 *   <dd>The list of resources that are embedded within this note.
 *   If the list of resources are omitted on a call to updateNote(), then
 *   the server will assume that no changes have been made to the resources.
 *   The binary contents of the resources must be provided when the resource
 *   is first sent to the service, but it will be omitted by the service when
 *   the Note is returned in the future.
 *   Maximum:  EDAM_NOTE_RESOURCES_MAX resources per note
 *   </dd>
 *
 * <dt>attributes</dt>
 *   <dd>A list of the attributes for this note.
 *   If the list of attributes are omitted on a call to updateNote(), then
 *   the server will assume that no changes have been made to the resources.
 *   </dd>
 *
 * <dt>tagNames</dt>
 *   <dd>May be provided by clients during calls to createNote() as an
 *   alternative to providing the tagGuids of existing tags.  If any tagNames
 *   are provided during createNote(), these will be found, or created if they
 *   don't already exist.  Created tags will have no parent (they will be at
 *   the top level of the tag panel).
 *   </dd>
 * </dl>
 */
struct Note {
  1:  optional  Guid guid,
  2:  optional  string title,
  3:  optional  string content,
  4:  optional  binary contentHash,
  5:  optional  i32 contentLength,
  6:  optional  Timestamp created,
  7:  optional  Timestamp updated,
  8:  optional  Timestamp deleted,
  9:  optional  bool active,
  10: optional  i32 updateSequenceNum,
  11: optional  string notebookGuid,
  12: optional  list<Guid> tagGuids,
  13: optional  list<Resource> resources,
  14: optional  NoteAttributes attributes,
  15: optional  list<string> tagNames
}


/**
 * If a Notebook has been opened to the public, the Notebook will have a
 * reference to one of these structures, which gives the location and optional
 * description of the externally-visible public Notebook.
 * <dl>
 * <dt>uri</dt>
 *   <dd>If this field is present, then the notebook is published for
 *   mass consumption on the Internet under the provided URI, which is
 *   relative to a defined base publishing URI defined by the service.
 *   This field can only be modified via the web service GUI ... publishing
 *   cannot be modified via an offline client.
 *   <br/>
 *   Length:  EDAM_PUBLISHING_URI_LEN_MIN - EDAM_PUBLISHING_URI_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_PUBLISHING_URI_REGEX
 *   </dd>
 *
 * <dt>order</dt>
 *   <dd>When the notes are publicly displayed, they will be sorted
 *   based on the requested criteria.
 *   </dd>
 *
 * <dt>ascending</dt>
 *   <dd>If this is set to true, then the public notes will be
 *   displayed in ascending order (e.g. from oldest to newest).  Otherwise,
 *   the notes will be displayed in descending order (e.g. newest to oldest).
 *   </dd>
 *
 * <dt>publicDescription</dt>
 *   <dd>This field may be used to provide a short
 *   description of the notebook, which may be displayed when (e.g.) the
 *   notebook is shown in a public view.  Can't begin or end with a space.
 *   <br/>
 *   Length:  EDAM_PUBLISHING_DESCRIPTION_LEN_MIN -
 *            EDAM_PUBLISHING_DESCRIPTION_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_PUBLISHING_DESCRIPTION_REGEX
 *   </dd>
 *
 * </dl>
 */
struct Publishing {
  1:  optional  string uri,
  2:  optional  NoteSortOrder order,
  3:  optional  bool ascending,
  4:  optional  string publicDescription
}

/**
 * If a Notebook contained in an Evernote Business account has been published
 * the to business library, the Notebook will have a reference to one of these
 * structures, which specifies how the Notebook will be represented in the
 * library.
 * 
 * <dl>
 * <dt>notebookDescription</dt>
 *   <dd>A short description of the notebook's content that will be displayed
 *       in the business library user interface. The description may not begin
 *       or end with whitespace.
 *   <br/>
 *   Length: EDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MIN -
 *           EDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_BUSINESS_NOTEBOOK_DESCRIPTION_REGEX
 *   </dd>
 *
 * <dt>privilege</dt>
 *   <dd>The privileges that will be granted to users who join the notebook through
 *       the business library.
 *   </dd>
 *
 * <dt>recommended</dt>
 *   <dd>Whether the notebook should be "recommended" when displayed in the business
 *       library user interface.
 *   </dd>
 * </dl>
 */
struct BusinessNotebook {
  1:  optional  string notebookDescription,
  2:  optional  SharedNotebookPrivilegeLevel privilege,
  3:  optional  bool recommended
}

/**
 * A named search associated with the account that can be quickly re-used.
 * <dl>
 * <dt>guid</dt>
 *   <dd>The unique identifier of this search.  Will be set by the
 *   service, so may be omitted by the client when creating.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>name</dt>
 *   <dd>The name of the saved search to display in the GUI.  The
 *   account may only contain one search with a given name (case-insensitive
 *   compare). Can't begin or end with a space.
 *   <br/>
 *   Length:  EDAM_SAVED_SEARCH_NAME_LEN_MIN - EDAM_SAVED_SEARCH_NAME_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_SAVED_SEARCH_NAME_REGEX
 *   </dd>
 *
 * <dt>query</dt>
 *   <dd>A string expressing the search to be performed.
 *   <br/>
 *   Length:  EDAM_SAVED_SEARCH_QUERY_LEN_MIN - EDAM_SAVED_SEARCH_QUERY_LEN_MAX
 *   </dd>
 *
 * <dt>format</dt>
 *   <dd>The format of the query string, to determine how to parse
 *   and process it.
 *   </dd>
 *
 * <dt>updateSequenceNum</dt>
 *   <dd>A number identifying the last transaction to
 *   modify the state of this object.  The USN values are sequential within an
 *   account, and can be used to compare the order of modifications within the
 *   service.
 *   </dd>
 * </dl>
 */
struct SavedSearch {
  1:  optional  Guid guid,
  2:  optional  string name,
  3:  optional  string query,
  4:  optional  QueryFormat format,
  5:  optional  i32 updateSequenceNum
}

/**
 * Shared notebooks represent a relationship between a notebook and a single
 * share invitation recipient.
 * <dl>
 * <dt>id</dt>
 * <dd>the primary identifier of the share</dd>
 *
 * <dt>userId</dt>
 * <dd>the user id of the owner of the notebook</dd>
 *
 * <dt>notebookGuid</dt>
 * <dd>the GUID of the associated notebook shared.</dd>
 *
 * <dt>email</dt>
 * <dd>the email address of the recipient - used by the notebook
 * owner to identify who they shared with.</dd>
 *
 * <dt>notebookModifiable</dt>
 * <dd>(DEPRECATED) a flag indicating the share is read/write -otherwise it's read
 *     only.  This field is deprecated in favor of the new "privilege" field.</dd>
 *
 * <dt>requireLogin</dt>
 * <dd>(DEPRECATED) indicates that a user must login to access the share.  This
 *     field is deprecated and will be "true" for all new shared notebooks.  It
 *     is read-only and ignored when creating or modifying a shared notebook,
 *     except that a shared notebook can be modified to require login.
 *     See "allowPreview" for information on privileges and shared notebooks.</dd>
 *
 * <dt>serviceCreated</dt>
 * <dd>the date the owner first created the share with the specific email
 *   address</dd>
 *
 * <dt>serviceUpdated</dt>
 * <dd>the date the shared notebook was last updated on the service.  This
 *     will be updated when authenticateToSharedNotebook is called the first
 *     time with a shared notebook requiring login (i.e. when the username is
 *     bound to that shared notebook).</dd>
 *
 * <dt>username</dt>
 * <dd>the username of the user who can access this share.
 *   Once it's assigned it cannot be changed.</dd>
 *
 * <dt>privilege</dt>
 * <dd>The privilege level granted to the notebook, activity stream, and
 *     invitations.  See the corresponding enumeration for details.</dd>
 *
 * <dt>allowPreview</dt>
 * <dd>Whether or not to grant "READ_NOTEBOOK" privilege without an
 *     authentication token, for authenticateToSharedNotebook(...).  With
 *     the change to "requireLogin" always being true for new shared
 *     notebooks, this is the only way to access a shared notebook without
 *     an authorization token.  This setting expires after the first use
 *     of authenticateToSharedNotebook(...) with a valid authentication
 *     token.</dd>
 * </dl>
 */
struct SharedNotebook {
  1:  optional i64 id,
  2:  optional i32 userId,
  3:  optional string notebookGuid,
  4:  optional string email,
  5:  optional bool notebookModifiable,  // deprecated
  6:  optional bool requireLogin,  // deprecated
  7:  optional Timestamp serviceCreated,
 10:  optional Timestamp serviceUpdated,
  8:  optional string shareKey,
  9:  optional string username,
 11:  optional SharedNotebookPrivilegeLevel privilege,
 12:  optional bool allowPreview
}

/**
 * This structure captures information about the types of operations
 * that cannot be performed on a given notebook with a type of
 * authenticated access and credentials.  The values filled into this
 * structure are based on then-current values in the server database
 * for shared notebooks and notebook publishing records, as well as
 * information related to the authentication token.  Information from
 * the authentication token includes the application that is accessing
 * the server, as defined by the permissions granted by consumer (api)
 * key, and the method used to obtain the token, for example via
 * authenticateToSharedNotebook, authenticateToBusiness, etc.  Note
 * that changes to values in this structure that are the result of
 * shared notebook or publishing record changes are communicated to
 * the client via a change in the notebook USN during sync.  It is
 * important to use the same access method, parameters, and consumer
 * key in order obtain correct results from the sync engine.
 *
 * The server has the final say on what is allowed as values may
 * change between calls to obtain NotebookRestrictions instances
 * and to operate on data on the service.
 *
 * If the following are set and true, then the given restriction is
 * in effect, as accessed by the same authentication token from which
 * the values were obtained.
 *
 * <dt>noReadNotes</dt>
 *   <dd>The client is not able to read notes from the service and
 *   the notebook is write-only.
 *   </dd>
 * <dt>noCreateNotes</dt>
 *   <dd>The client may not create new notes in the notebook.
 *   </dd>
 * <dt>noUpdateNotes</dt>
 *   <dd>The client may not update notes currently in the notebook.
 *   </dd>
 * <dt>noExpungeNotes</dt>
 *   <dd>The client may not expunge notes currently in the notebook.
 *   </dd>
 * <dt>noShareNotes</dt>
 *   <dd>The client may not share notes in the notebook via the
 *   shareNote method.
 *   </dd>
 * <dt>noEmailNotes</dt>
 *   <dd>The client may not e-mail notes via the Evernote service by
 *   using the emailNote method.
 *   </dd>
 * <dt>noSendMessageToRecipients</dt>
 *   <dd>The client may not send messages to the share recipients of
 *   the notebook.
 *   </dd>
 * <dt>noUpdateNotebook</dt>
 *   <dd>The client may not update the Notebook object itself, for
 *   example, via the updateNotebook method.
 *   </dd>
 * <dt>noExpungeNotebook</dt>
 *   <dd>The client may not expunge the Notebook object itself, for
 *   example, via the expungeNotebook method.
 *   </dd>
 * <dt>noSetDefaultNotebook</dt>
 *   <dd>The client may not set this notebook to be the default notebook.
 *   The caller should leave Notebook.defaultNotebook unset.
 *   </dd>
 * <dt>noSetNotebookStack</dt>
 *   <dd>If the client is able to update the Notebook, the Notebook.stack
 *   value may not be set.
 *   </dd>
 * <dt>noPublishToPublic</dt>
 *   <dd>The client may not change the publish the notebook to the public.
 *   For example, business notebooks may not be shared publicly.
 *   </dd>
 * <dt>noPublishToBusinessLibrary</dt>
 *   <dd>The client may not publish the notebook to the business library.
 *   </dd>
 * <dt>noCreateTags</dt>
 *   <dd>The client may not complete an operation that results in a new tag
 *   being created in the owner's account.
 *   </dd>
 * <dt>noUpdateTags</dt>
 *   <dd>The client may not update tags in the owner's account.
 *   </dd>
 * <dt>noExpungeTags</dt>
 *   <dd>The client may not expunge tags in the owner's account.
 *   </dd>
 * <dt>noSetParentTag</dt>
 *   <dd>If the client is able to create or update tags in the owner's account,
 *   then they will not be able to set the parent tag.  Leave the value unset.
 *   </dd>
 * <dt>noCreateSharedNotebooks</dt>
 *   <dd>The client is unable to create shared notebooks for the notebook.
 *   </dd>
 * <dt>updateWhichSharedNotebookRestrictions</dt>
 *   <dd>Restrictions on which shared notebook instances can be updated.  If the
 *   value is not set or null, then the client can update any of the shared notebooks
 *   associated with the notebook on which the NotebookRestrictions are defined.
 *   See the enumeration for further details.
 *   </dd>          
 * <dt>expungeWhichSharedNotebookRestrictions</dt>
 *   <dd>Restrictions on which shared notebook instances can be expunged.  If the
 *   value is not set or null, then the client can expunge any of the shared notebooks
 *   associated with the notebook on which the NotebookRestrictions are defined.
 *   See the enumeration for further details.
 *   </dd>
 */
struct NotebookRestrictions {
  1:  optional bool noReadNotes,
  2:  optional bool noCreateNotes,
  3:  optional bool noUpdateNotes,
  4:  optional bool noExpungeNotes,
  5:  optional bool noShareNotes,
  6:  optional bool noEmailNotes,
  7:  optional bool noSendMessageToRecipients,
  8:  optional bool noUpdateNotebook,
  9:  optional bool noExpungeNotebook,
  10: optional bool noSetDefaultNotebook,
  11: optional bool noSetNotebookStack,
  12: optional bool noPublishToPublic,
  13: optional bool noPublishToBusinessLibrary,
  14: optional bool noCreateTags,
  15: optional bool noUpdateTags,
  16: optional bool noExpungeTags,
  17: optional bool noSetParentTag,
  18: optional bool noCreateSharedNotebooks,
  19: optional SharedNotebookInstanceRestrictions updateWhichSharedNotebookRestrictions,
  20: optional SharedNotebookInstanceRestrictions expungeWhichSharedNotebookRestrictions
}

/**
 * A unique container for a set of notes.
 * <dl>
 * <dt>guid</dt>
 *   <dd>The unique identifier of this notebook.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>name</dt>
 *   <dd>A sequence of characters representing the name of the
 *   notebook.  May be changed by clients, but the account may not contain two
 *   notebooks with names that are equal via a case-insensitive comparison.
 *   Can't begin or end with a space.
 *   <br/>
 *   Length:  EDAM_NOTEBOOK_NAME_LEN_MIN - EDAM_NOTEBOOK_NAME_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_NOTEBOOK_NAME_REGEX
 *   </dd>
 *
 * <dt>updateSequenceNum</dt>
 *   <dd>A number identifying the last transaction to
 *   modify the state of this object.  The USN values are sequential within an
 *   account, and can be used to compare the order of modifications within the
 *   service.
 *   </dd>
 *
 * <dt>defaultNotebook</dt>
 *   <dd>If true, this notebook should be used for new notes
 *   whenever the user has not (or cannot) specify a desired target notebook.
 *   For example, if a note is submitted via SMTP email.
 *   The service will maintain at most one defaultNotebook per account.
 *   If a second notebook is created or updated with defaultNotebook set to
 *   true, the service will automatically update the prior notebook's
 *   defaultNotebook field to false.  If the default notebook is deleted
 *   (i.e. "active" set to false), the "defaultNotebook" field will be
 *   set to false by the service.  If the account has no default notebook
 *   set, the service will use the most recent notebook as the default.
 *   </dd>
 *
 * <dt>serviceCreated</dt>
 *   <dd>The time when this notebook was created on the
 *   service. This will be set on the service during creation, and the service
 *   will provide this value when it returns a Notebook to a client.
 *   The service will ignore this value if it is sent by clients.
 *   </dd>
 *
 * <dt>serviceUpdated</dt>
 *   <dd>The time when this notebook was last modified on the
 *   service.  This will be set on the service during creation, and the service
 *   will provide this value when it returns a Notebook to a client.
 *   The service will ignore this value if it is sent by clients.
 *   </dd>
 *
 * <dt>publishing</dt>
 *   <dd>If the Notebook has been opened for public access, or
 *   business users shared with their business (i.e. if 'published' is
 *   set to true), then this will point to the set of publishing
 *   information for the Notebook (URI, description, etc.).  A
 *   Notebook cannot be published without providing this information,
 *   but it will persist for later use if publishing is ever disabled
 *   on the Notebook.  Clients that do not wish to change the
 *   publishing behavior of a Notebook should not set this value when
 *   calling NoteStore.updateNotebook().
 *   </dd>
 *
 * <dt>published</dt>
 *   <dd>If this is set to true, then the Notebook will be
 *   accessible either to the public, or for business users to their business,
 *   via the 'publishing' specification, which must also be set.  If this is set
 *   to false, the Notebook will not be available to the public (or business).
 *   Clients that do not wish to change the publishing behavior of a Notebook
 *   should not set this value when calling NoteStore.updateNotebook().
 *   </dd>
 *
 * <dt>stack</dt>
 *   <dd>If this is set, then the notebook is visually contained within a stack
 *   of notebooks with this name.  All notebooks in the same account with the
 *   same 'stack' field are considered to be in the same stack.
 *   Notebooks with no stack set are "top level" and not contained within a
 *   stack.
 *   </dd>
 *
 * <dt>sharedNotebookIds</dt>
 *   <dd><i>DEPRECATED</i> - replaced by sharedNotebooks.</dd>
 *
 * <dt>sharedNotebooks</dt>
 *   <dd>The list of recipients to whom this notebook has been shared
 *   (one SharedNotebook object per recipient email address). This field will
 *   be unset if you do not have permission to access this data. If you are
 *   accessing the notebook as the owner or via a shared notebook that is
 *   modifiable, then you have access to this data and the value will be set.
 *   This field is read-only. Clients may not make changes to shared notebooks
 *   via this field.
 *   </dd>
 *
 * <dt>businessNotebook</dt>
 *   <dd>If the notebook is part of a business account and has been published to the
 *   business library, this will contain information for the library listing.
 *   The presence or absence of this field is not a reliable test of whether a given
 *   notebook is in fact a business notebook - the field is only used when a notebook is or
 *   has been published to the business library.
 *   </dd>
 *
 * <dt>contact</dt>
 *   <dd>Intended for use with Business accounts, this field identifies the user who
 *   has been designated as the "contact".  For notebooks created in business
 *   accounts, the server will automatically set this value to the user who created
 *   the notebook unless Notebook.contact.username has been set, in which that value
 *   will be used.  When updating a notebook, it is common to leave Notebook.contact
 *   field unset, indicating that no change to the value is being requested and that
 *   the existing value, if any, should be preserved.
 *   </dd>
 *
 * </dl>
 */
struct Notebook {
  1:  optional  Guid guid,
  2:  optional  string name,
  5:  optional  i32 updateSequenceNum,
  6:  optional  bool defaultNotebook,
  7:  optional  Timestamp serviceCreated,
  8:  optional  Timestamp serviceUpdated,
  10: optional  Publishing publishing,
  11: optional  bool published,
  12: optional  string stack,
  13: optional  list<i64> sharedNotebookIds,
  14: optional  list<SharedNotebook> sharedNotebooks,
  15: optional  BusinessNotebook businessNotebook,
  16: optional  User contact,
  17: optional  NotebookRestrictions restrictions
}

/**
 * A link in an users account that refers them to a public or individual share in
 * another user's account.
 *
 * <dl>
 * <dt>shareName</dt>
 * <dd>the display name of the shared notebook.
 *   The link owner can change this.</dd>
 *
 * <dt>username</dt>
 * <dd>the username of the user who owns the shared or public notebook</dd>
 *
 * <dt>shardId</dt>
 * <dd>the shard ID of the notebook if the notebook is not public</dt>
 *
 * <dt>shareKey</dt>
 * <dd>the secret key that provides access to the shared notebook</dd>
 *
 * <dt>uri</dt>
 * <dd>the identifier of the public notebook</dd>
 *
 * <dt>guid</dt>
 *   <dd>The unique identifier of this linked notebook.  Will be set whenever
 *   a linked notebook is retrieved from the service, but may be null when a client
 *   is creating a linked notebook.
 *   <br/>
 *   Length:  EDAM_GUID_LEN_MIN - EDAM_GUID_LEN_MAX
 *   <br/>
 *   Regex:  EDAM_GUID_REGEX
 *   </dd>
 *
 * <dt>updateSequenceNum</dt>
 *   <dd>A number identifying the last transaction to
 *   modify the state of this object.  The USN values are sequential within an
 *   account, and can be used to compare the order of modifications within the
 *   service.
 *   </dd>
 *
 * <dt>noteStoreUrl</dt>
 *   <dd>
 *   This field will contain the full URL that clients should use to make
 *   NoteStore requests to the server shard that contains that notebook's data.
 *   I.e. this is the URL that should be used to create the Thrift HTTP client
 *   transport to send messages to the NoteStore service for the account.
 *   </dd>
 *
 * <dt>webApiUrlPrefix:</dt>
 *   <dd>
 *   This field will contain the initial part of the URLs that should be used
 *   to make requests to Evernote's thin client "web API", which provide
 *   optimized operations for clients that aren't capable of manipulating
 *   the full contents of accounts via the full Thrift data model. Clients
 *   should concatenate the relative path for the various servlets onto the
 *   end of this string to construct the full URL, as documented on our
 *   developer web site.
 *   </dd>
 *
 * <dt>stack</dt>
 *   <dd>If this is set, then the notebook is visually contained within a stack
 *   of notebooks with this name.  All notebooks in the same account with the
 *   same 'stack' field are considered to be in the same stack.
 *   Notebooks with no stack set are "top level" and not contained within a
 *   stack.  The link owner can change this and this field is for the benefit
 *   of the link owner.
 *   </dd>
 *
 * <dt>businessId</dt>
 *   <dd>If set, this will be the unique identifier for the business that owns
 *   the notebook to which the linked notebook refers.
 *
 * </dl>
 */
struct LinkedNotebook {
  2:  optional string shareName,
  3:  optional string username,
  4:  optional string shardId,
  5:  optional string shareKey,
  6:  optional string uri,
  7:  optional Guid guid,
  8:  optional i32 updateSequenceNum,
  9:  optional string noteStoreUrl,
  10: optional string webApiUrlPrefix,
  11: optional string stack,
  12: optional i32 businessId
}

/**
 * A structure that describes a notebook or a user's relationship with
 * a notebook. NotebookDescriptor is expected to remain a lighter-weight
 * structure when compared to Notebook.
 * <dl>
 * <dt>guid</dt>
 *   <dd>The unique identifier of the notebook.
 *   </dd>
 *
 * <dt>notebookDisplayName</dt>
 *   <dd>A sequence of characters representing the name of the
 *   notebook.
 *   </dd>
 *
 * <dt>contactName</dt>
 *   <dd>The User.name value of the notebook's "contact".
 *   </dd>
 *
 * <dt>hasSharedNotebook</dt>
 *   <dd>Whether a SharedNotebook record exists between the calling user and this
 *   notebook.
 *   </dd>
 *
 * <dt>joinedUserCount</dt>
 *   <dd>The number of users who have joined this notebook.
 *   </dd>
 *
 * </dl>
 */
struct NotebookDescriptor {
  1: optional Guid guid,
  2: optional string notebookDisplayName,
  3: optional string contactName,
  4: optional bool hasSharedNotebook,
  5: optional i32 joinedUserCount
}
