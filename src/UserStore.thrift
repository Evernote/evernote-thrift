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
const i16 EDAM_VERSION_MINOR = 23

//============================= Enumerations ==================================

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
 *   DEPRECATED - Client applications should have no need to use this field.
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
struct PublicUserInfo {
  1:  required  Types.UserID userId,
  2:  required  string shardId,
  3:  optional  Types.PrivilegeLevel privilege,
  4:  optional  string username,
  5:  optional  string noteStoreUrl,
  6:  optional  string webApiUrlPrefix
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
  11: optional bool enableTwitterSharing,
  12: optional bool enableLinkedInSharing,
  13: optional bool enablePublicNotebooks
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
   * This is used to check a username and password in order to create a
   * short-lived authentication session that can be used for further actions.
   *
   * This function is only available to Evernote's internal applications.
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
   *   The "consumer key" portion of the API key issued to the client application
   *   by Evernote.
   *
   * @param consumerSecret
   *   The "consumer secret" portion of the API key issued to the client application
   *   by Evernote.
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
   * This is used to check a username and password in order to create a
   * long-lived authentication token that can be used for further actions.
   *
   * This function is not available to most third party applications,
   * which typically authenticate using OAuth as
   * described at
   * <a href="http://dev.evernote.com/documentation/cloud/">dev.evernote.com</a>.
   * If you believe that your application requires permission to authenticate
   * using username and password instead of OAuth, please contact Evernote
   * developer support by visiting 
   * <a href="http://dev.evernote.com">dev.evernote.com</a>.
   *
   * @param username
   *   The username or registered email address of the account to
   *   authenticate against.
   *
   * @param password
   *   The plaintext password to check against the account.  Since
   *   this is not protected by the EDAM protocol, this information must be
   *   provided over a protected transport (i.e. SSL).
   *
   * @param consumerKey
   *   The "consumer key" portion of the API key issued to the client application
   *   by Evernote.
   *
   * @param consumerSecret
   *   The "consumer secret" portion of the API key issued to the client application
   *   by Evernote.
   *
   * @param deviceIdentifier
   *   An optional string, no more than 32 characters in length, that uniquely identifies 
   *   the device from which the authentication is being performed. This string allows 
   *   the service to return the same authentication token when a given application 
   *   requests authentication repeatedly from the same device. This may happen when the 
   *   user logs out of an application and then logs back in, or when the application is 
   *   uninstalled and later reinstalled. If no reliable device identifier can be created, 
   *   this value should be omitted. If set, the device identifier must be between
   *   1 and EDAM_DEVICE_ID_LEN_MAX characters long and must match the regular expression
   *   EDAM_DEVICE_ID_REGEX.
   *
   * @param deviceDescription
   *   A description of the device from which the authentication is being performed.
   *   This field is displayed to the user in a list of authorized applications to
   *   allow them to distinguish between multiple tokens issued to the same client
   *   application on different devices. For example, the Evernote iOS client on
   *   a user's iPhone and iPad might pass the iOS device names "Bob's iPhone" and
   *   "Bob's iPad". The device description must be between 1 and 
   *   EDAM_DEVICE_DESCRIPTION_LEN_MAX characters long and must match the regular 
   *   expression EDAM_DEVICE_DESCRIPTION_REGEX.
   *
   * @return
   *   The result of the authentication. The level of detail provided in the returned
   *   AuthenticationResult.User structure depends on the access level granted by 
   *   calling application's API key.
   *
   * @throws EDAMUserException <ul>
   *   <li> DATA_REQUIRED "username" - username is empty
   *   <li> DATA_REQUIRED "password" - password is empty
   *   <li> DATA_REQUIRED "consumerKey" - consumerKey is empty
   *   <li> DATA_REQUIRED "consumerSecret" - consumerSecret is empty
   *   <li> DATA_REQUIRED "deviceDescription" - deviceDescription is empty
   *   <li> BAD_DATA_FORMAT "deviceDescription" - deviceDescription is not valid.
   *   <li> BAD_DATA_FORMAT "deviceIdentifier" - deviceIdentifier is not valid.
   *   <li> INVALID_AUTH "username" - username not found
   *   <li> INVALID_AUTH "password" - password did not match
   *   <li> INVALID_AUTH "consumerKey" - consumerKey is not authorized
   *   <li> INVALID_AUTH "consumerSecret" - consumerSecret is incorrect
   *   <li> PERMISSION_DENIED "User.active" - user account is closed
   *   <li> PERMISSION_DENIED "User.tooManyFailuresTryAgainLater" - user has
   *     failed authentication too often
   * </ul>
   */
  AuthenticationResult authenticateLongSession(1: string username,
                                               2: string password,
                                               3: string consumerKey,
                                               4: string consumerSecret,
                                               5: string deviceIdentifier,
                                               6: string deviceDescription)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),


  /**
   * This is used to take an existing authentication token that grants access
   * to an individual user account (returned from 'authenticate', 
   * 'authenticateLongSession' or an OAuth authorization) and obtain an additional 
   * authentication token that may be used to access business notebooks if the user
   * is a member of an Evernote Business account.
   *
   * The resulting authentication token may be used to make NoteStore API calls
   * against the business using the NoteStore URL returned in the result.
   *
   * @param authenticationToken 
   *   The authentication token for the user. This may not be a shared authentication
   *   token (returned by NoteStore.authenticateToSharedNotebook or 
   *   NoteStore.authenticateToSharedNote) or a business authentication token.
   * 
   * @return
   *   The result of the authentication, with the token granting access to the
   *   business in the result's 'authenticationToken' field. The URL that must
   *   be used to access the business account NoteStore will be returned in the
   *   result's 'noteStoreUrl' field.  The 'User' field will
   *   not be set in the result.
   *
   * @throws EDAMUserException <ul>
   *   <li> PERMISSION_DENIED "authenticationToken" - the provided authentication token
   *        is a shared or business authentication token. </li>
   *   <li> PERMISSION_DENIED "Business" - the user identified by the provided 
   *        authentication token is not currently a member of a business. </li>
   *   <li> PERMISSION_DENIED "Business.status" - the business that the user is a 
   *        member of is not currently in an active status. </li>
   * </ul>
   */
  AuthenticationResult authenticateToBusiness(1: string authenticationToken)
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
   *   the result's 'authenticationToken' field.  The 'User' field will
   *   not be set in the result.
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
  Types.PremiumInfo getPremiumInfo(1: string authenticationToken)
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
