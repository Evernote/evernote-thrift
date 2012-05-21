/*
 * Copyright 2007-2012 Evernote Corporation
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
 * This file contains the EDAM protocol interface for operations to query
 * and/or authenticate users.
 */

include "Types.thrift"
include "Errors.thrift"

namespace as3 com.evernote.edam.userstore
namespace java com.evernote.edam.userstore
namespace csharp Evernote.EDAM.UserStore
namespace py evernote.edam.userstore
namespace cpp evernote.edam
namespace rb Evernote.EDAM.UserStore
namespace php EDAM.UserStore
namespace cocoa EDAM
namespace perl EDAMUserStore


/**
 * The major version number for the current revision of the EDAM protocol.
 * Clients pass this to the service using UserStore.checkVersion at the
 * beginning of a session to confirm that they are not out of date.
 */
const i16 EDAM_VERSION_MAJOR = 1

/**
 * The minor version number for the current revision of the EDAM protocol.
 * Clients pass this to the service using UserStore.checkVersion at the
 * beginning of a session to confirm that they are not out of date.
 */
const i16 EDAM_VERSION_MINOR = 21

//============================= Enumerations ==================================
/**
 * Enumeration of Sponsored Group Roles
 */
enum SponsoredGroupRole {
  GROUP_MEMBER = 1,
  GROUP_ADMIN = 2,
  GROUP_OWNER = 3
}

/**
 * This structure is used to provide publicly-available user information
 * about a particular account.
 *<dl>
 * <dt>userId:</dt>
 *   <dd>
 *   The unique numeric user identifier for the user account.
 *   </dd>
 * <dt>shardId:</dt>
 *   <dd>
 *   The name of the virtual server that manages the state of
 *   this user. This value is used internally to determine which system should
 *   service requests about this user's data.
 *   </dd>
 * <dt>privilege:</dt>
 *   <dd>
 *   The privilege level of the account, to determine whether
 *   this is a Premium or Free account.
 *   </dd>
 * <dt>noteStoreUrl:</dt>
 *   <dd>
 *   This field will contain the full URL that clients should use to make
 *   NoteStore requests to the server shard that contains that user's data.
 *   I.e. this is the URL that should be used to create the Thrift HTTP client
 *   transport to send messages to the NoteStore service for the account.
 *   </dd>
 * </dl> 
 */
struct PublicUserInfo {
  1:  required  Types.UserID userId,
  2:  required  string shardId,
  3:  optional  Types.PrivilegeLevel privilege,
  4:  optional  string username,
  5:  optional  string noteStoreUrl
}

/**
 * This structure is used to provide information about a user's Premium account.
 *<dl>
 * <dt>currentTime:</dt>
 *   <dd>
 *   The server-side date and time when this data was generated.
 *   </dd>
 * <dt>premium:</dt>
 *   <dd>
 *	 True if the user's account is Premium.
 *   </dd>
 * <dt>premiumRecurring</dt>
 *   <dd>
 *   True if the user's account is Premium and has a recurring payment method.
 *   </dd>
 * <dt>premiumExpirationDate:</dt>
 *   <dd>
 *   The date when the user's Premium account expires, or the date when the
 *   user's account will be charged if it has a recurring payment method.
 *   </dd>
 * <dt>premiumExtendable:</dt>
 *   <dd>
 *   True if the user is eligible for purchasing Premium account extensions. 
 *   </dd>
 * <dt>premiumPending:</dt>
 *   <dd>
 *   True if the user's Premium account is pending payment confirmation 
 *   </dd>
 * <dt>premiumCancellationPending:</dt>
 *   <dd>
 *   True if the user has requested that no further charges to be made; the
 *   Premium account will remain active until it expires.
 *   </dd>
 * <dt>canPurchaseUploadAllowance:</dt>
 *   <dd>
 *   True if the user is eligible for purchasing additional upload allowance.
 *   </dd>
 * <dt>sponsoredGroupName:</dt>
 *   <dd>
 *   The name of the sponsored group that the user is part of.
 *   </dd>
 * <dt>sponsoredGroupRole:</dt>
 *   <dd>
 *   The role of the user within a sponsored group.
 *   </dd>
 * </dl> 
 */
struct PremiumInfo {
  1:  required Types.Timestamp currentTime,
  2:  required bool premium,
  3:  required bool premiumRecurring,
  4:  optional Types.Timestamp premiumExpirationDate,
  5:  required bool premiumExtendable,
  6:  required bool premiumPending,
  7:  required bool premiumCancellationPending,
  8:  required bool canPurchaseUploadAllowance,
  9:  optional string sponsoredGroupName,
  10: optional SponsoredGroupRole sponsoredGroupRole
 }

/**
 * When an authentication (or re-authentication) is performed, this structure
 * provides the result to the client.
 *<dl>
 * <dt>currentTime:</dt>
 *   <dd>
 *   The server-side date and time when this result was
 *   generated.
 *   </dd>
 * <dt>authenticationToken:</dt>
 *   <dd>
 *   Holds an opaque, ASCII-encoded token that can be
 *   used by the client to perform actions on a NoteStore.
 *   </dd>
 * <dt>expiration:</dt>
 *   <dd>
 *   Holds the server-side date and time when the
 *   authentication token will expire.
 *   This time can be compared to "currentTime" to produce an expiration
 *   time that can be reconciled with the client's local clock.
 *   </dd>
 * <dt>user:</dt>
 *   <dd>
 *   Holds the information about the account which was 
 *   authenticated if this was a full authentication.  May be absent if this
 *   particular authentication did not require user information.
 *   </dd>
 * <dt>publicUserInfo:</dt>
 *   <dd>
 *   If this authentication result was achieved without full permissions to
 *   access the full User structure, this field may be set to give back
 *   a more limited public set of data.
 *   </dd>
 * <dt>noteStoreUrl:</dt>
 *   <dd>
 *   This field will contain the full URL that clients should use to make
 *   NoteStore requests to the server shard that contains that user's data.
 *   I.e. this is the URL that should be used to create the Thrift HTTP client
 *   transport to send messages to the NoteStore service for the account.
 *   </dd>
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
 * </dl>
 */
struct AuthenticationResult {
  1:  required Types.Timestamp currentTime,
  2:  required string authenticationToken,  
  3:  required Types.Timestamp expiration,
  4:  optional Types.User user,
  5:  optional PublicUserInfo publicUserInfo,
  6:  optional string noteStoreUrl,
  7:  optional string webApiUrlPrefix
}

/**
 * This structure describes a collection of bootstrap settings.
 *<dl>
 * <dt>serviceHost:</dt>
 *   <dd>
 *   The hostname and optional port for composing Evernote web service URLs. 
 *   This URL can be used to access the UserStore and related services, 
 *   but must not be used to compose the NoteStore URL. Client applications
 *   must handle serviceHost values that include only the hostname 
 *   (e.g. www.evernote.com) or both the hostname and port (e.g. www.evernote.com:8080).
 *   If no port is specified, or if port 443 is specified, client applications must 
 *   use the scheme "https" when composing URLs. Otherwise, a client must use the 
 *   scheme "http". 
 * </dd> 
 * <dt>marketingUrl:</dt>
 *   <dd>
 *   The URL stem for the Evernote corporate marketing website, e.g. http://www.evernote.com.
 *   This stem can be used to compose website URLs. For example, the URL of the Evernote
 *   Trunk is composed by appending "/about/trunk/" to the value of marketingUrl. 
 *   </dd> 
 * <dt>supportUrl:</dt>
 *   <dd>
 *   The full URL for the Evernote customer support website, e.g. https://support.evernote.com. 
 *   </dd> 
 * <dt>accountEmailDomain:</dt>
 *   <dd>
 *   The domain used for an Evernote user's incoming email address, which allows notes to
 *   be emailed into an account. E.g. m.evernote.com. 
 *   </dd> 
 * <dt>enableFacebookSharing:</dt>
 *   <dd>
 *   Whether the client application should enable sharing of notes on Facebook.
 *   </dd> 
 * <dt>enableGiftSubscriptions:</dt>
 *   <dd>
 *   Whether the client application should enable gift subscriptions.
 *   </dd> 
 * <dt>enableSupportTickets:</dt>
 *   <dd>
 *   Whether the client application should enable in-client creation of support tickets.
 *   </dd> 
 * <dt>enableSharedNotebooks:</dt>
 *   <dd>
 *   Whether the client application should enable shared notebooks.
 *   </dd> 
 * <dt>enableSingleNoteSharing:</dt>
 *   <dd>
 *   Whether the client application should enable single note sharing.
 *   </dd> 
 * <dt>enableSponsoredAccounts:</dt>
 *   <dd>
 *   Whether the client application should enable sponsored accounts.
 *   </dd> 
 * <dt>enableTwitterSharing:</dt>
 *   <dd>
 *   Whether the client application should enable sharing of notes on Twitter.
 *   </dd> 
 * </dl> 
 */
struct BootstrapSettings {
  1: required string serviceHost,
  2: required string marketingUrl,
  3: required string supportUrl,
  4: required string accountEmailDomain,
  5: optional bool enableFacebookSharing,
  6: optional bool enableGiftSubscriptions,
  7: optional bool enableSupportTickets,
  8: optional bool enableSharedNotebooks,
  9: optional bool enableSingleNoteSharing,
  10: optional bool enableSponsoredAccounts,
  11: optional bool enableTwitterSharing
}

/**
 * This structure describes a collection of bootstrap settings.
 *<dl>
 * <dt>name:</dt>
 *   <dd>
 *   The unique name of the profile, which is guaranteed to remain consistent across
 *   calls to getBootstrapInfo.
 *   </dd> 
 * <dt>settings:</dt>
 *   <dd>
 *   The settings for this profile.
 *   </dd> 
 * </dl> 
 */
struct BootstrapProfile {
  1: required string name,
  2: required BootstrapSettings settings,
}

/**
 * This structure describes a collection of bootstrap profiles.
 *<dl>
 * <dt>profiles:</dt>
 *   <dd>
 *   List of one or more bootstrap profiles, in descending 
 *   preference order.
 *   </dd> 
 * </dl> 
 */
struct BootstrapInfo {
  1: required list<BootstrapProfile> profiles
}

/**
 * Service:  UserStore
 * <p>
 * The UserStore service is primarily used by EDAM clients to establish
 * authentication via username and password over a trusted connection (e.g.
 * SSL).  A client's first call to this interface should be checkVersion() to
 * ensure that the client's software is up to date.
 * </p>
 * All calls which require an authenticationToken may throw an 
 * EDAMUserException for the following reasons: 
 *  <ul>
 *   <li> AUTH_EXPIRED "authenticationToken" - token has expired
 *   <li> BAD_DATA_FORMAT "authenticationToken" - token is malformed
 *   <li> DATA_REQUIRED "authenticationToken" - token is empty
 *   <li> INVALID_AUTH "authenticationToken" - token signature is invalid
 * </ul>
 */
service UserStore {

  /**
   * This should be the first call made by a client to the EDAM service.  It
   * tells the service what protocol version is used by the client.  The
   * service will then return true if the client is capable of talking to
   * the service, and false if the client's protocol version is incompatible
   * with the service, so the client must upgrade.  If a client receives a
   * false value, it should report the incompatibility to the user and not
   * continue with any more EDAM requests (UserStore or NoteStore).
   *
   * @param clientName
   *   This string provides some information about the client for
   *   tracking/logging on the service.  It should provide information about
   *   the client's software and platform.  The structure should be:
   *   application/version; platform/version; [ device/version ]
   *   E.g.   "Evernote Windows/3.0.1; Windows/XP SP3" or
   *   "Evernote Clipper/1.0.1; JME/2.0; Motorola RAZR/2.0;
   *
   * @param edamVersionMajor
   *   This should be the major protocol version that was compiled by the
   *   client.  This should be the current value of the EDAM_VERSION_MAJOR
   *   constant for the client.
   *
   * @param edamVersionMinor
   *   This should be the major protocol version that was compiled by the
   *   client.  This should be the current value of the EDAM_VERSION_MINOR
   *   constant for the client.
   */
  bool checkVersion(1: string clientName,
                    2: i16 edamVersionMajor = EDAM_VERSION_MAJOR,
                    3: i16 edamVersionMinor = EDAM_VERSION_MINOR),

  /**
   * This provides bootstrap information to the client. Various bootstrap
   * profiles and settings may be used by the client to configure itself.
   *
   * @param locale
   *   The client's current locale, expressed in language[_country]
   *   format. E.g., "en_US". See ISO-639 and ISO-3166 for valid
   *   language and country codes. 
   *
   * @return
   *   The bootstrap information suitable for this client.
   */                 
  BootstrapInfo getBootstrapInfo(1: string locale),

  /**
   * This is used to check a username and password in order to create an
   * authentication session that could be used for further actions.
   * 
   * This function is only availabe to Evernote's internal applications.
   * Third party applications must authenticate using OAuth as
   * described at 
   * <a href="http://dev.evernote.com/documentation/cloud/">dev.evernote.com</a>.
   *
   * @param username
   *   The username (not numeric user ID) for the account to
   *   authenticate against.  This function will also accept the user's
   *   registered email address in this parameter.
   *
   * @param password
   *   The plaintext password to check against the account.  Since
   *   this is not protected by the EDAM protocol, this information must be
   *   provided over a protected transport (e.g. SSL).
   *
   * @param consumerKey
   *   A unique identifier for this client application, provided by Evernote
   *   to developers who request an API key.  This must be provided to identify
   *   the client.
   *
   * @param consumerSecret
   *   If the client was given a "consumer secret" when the API key was issued,
   *   it must be provided here to authenticate the application itself.
   *
   * @return
   *   The result of the authentication.  If the authentication was successful,
   *   the AuthenticationResult.user field will be set with the full information
   *   about the User.
   *
   * @throws EDAMUserException <ul>
   *   <li> DATA_REQUIRED "username" - username is empty 
   *   <li> DATA_REQUIRED "password" - password is empty
   *   <li> DATA_REQUIRED "consumerKey" - consumerKey is empty
   *   <li> INVALID_AUTH "username" - username not found
   *   <li> INVALID_AUTH "password" - password did not match
   *   <li> INVALID_AUTH "consumerKey" - consumerKey is not authorized
   *   <li> INVALID_AUTH "consumerSecret" - consumerSecret is incorrect
   *   <li> PERMISSION_DENIED "User.active" - user account is closed
   *   <li> PERMISSION_DENIED "User.tooManyFailuresTryAgainLater" - user has
   *     failed authentication too often
   * </ul>
   */
  AuthenticationResult authenticate(1: string username,
                                    2: string password,
                                    3: string consumerKey,
                                    4: string consumerSecret)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * This is used to take an existing authentication token (returned from
   * 'authenticate') and exchange it for a newer token which will not expire
   * as soon.  This must be invoked before the previous token expires.
   *
   * This function is only availabe to Evernote's internal applications.
   *
   * @param authenticationToken
   *   The previous authentication token from the authenticate() result.
   *
   * @return
   *   The result of the authentication, with the new token in
   *   the result's "authentication" field.  The User field will
   *   not be set in the reply.
   */
  AuthenticationResult refreshAuthentication(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Returns the User corresponding to the provided authentication token,
   * or throws an exception if this token is not valid.
   * The level of detail provided in the returned User structure depends on
   * the access level granted by the token, so a web service client may receive
   * fewer fields than an integrated desktop client.
   */    
  Types.User getUser(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Asks the UserStore about the publicly available location information for
   * a particular username.
   *
   * @throws EDAMUserException <ul>
   *   <li> DATA_REQUIRED "username" - username is empty 
   * </ul>
   */
  PublicUserInfo getPublicUserInfo(1: string username)
    throws (1: Errors.EDAMNotFoundException notFoundException,
    	    2: Errors.EDAMSystemException systemException,
    	    3: Errors.EDAMUserException userException),

  /**
   * Returns information regarding a user's Premium account corresponding to the
   * provided authentication token, or throws an exception if this token is not
   * valid.
   */
  PremiumInfo getPremiumInfo(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException)  

  /**
   * Returns the URL that should be used to talk to the NoteStore for the
   * account represented by the provided authenticationToken.
   * This method isn't needed by most clients, who can retrieve the correct
   * NoteStore URL from the AuthenticationResult returned from the authenticate
   * or refreshAuthentication calls. This method is typically only needed
   * to look up the correct URL for a long-lived session token (e.g. for an
   * OAuth web service).
   */
  string getNoteStoreUrl(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException)  

}
