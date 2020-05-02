The JWFriendlyObstructions target provides the best practice implementation for registering friendly obstructions with the Goole IMA SDK.

When ad viewability via the OMSDK is calculated, all views overlaying the media element are considered obstructions and reduce the viewability rate. Friendly obstructions are views such as video controls that are essential to the user’s experience but do not impact viewability. Once registered as such, these controls
 are excluded from ad viewability measurements. These controls must only be fully transparent overlays or small buttons. Any other non-control views must not be registered.
