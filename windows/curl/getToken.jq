if type != "object" then
  error("Authentication response is not a JSON object")
elif ((.access_token // "") | tostring | length) == 0 then
  error(
    (
      .error_description //
      .error //
      .message //
      "Authentication response does not contain an access token"
    )
    | tostring
  )
else
  .access_token
end