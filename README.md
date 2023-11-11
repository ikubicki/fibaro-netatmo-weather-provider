# Netatmo weather provider

An alternative to YR weather provider, that is default weather provider for HC3.

This quick application creates weather device only.

Data updates every 5 minutes by default.

## Configuration

`ClientID` - Netatmo client ID

`ClientSecret` - Netatmo client secret

`RefreshToken` - Refresh token

### Optional values

`DeviceID` - identifier of Netatmo Weather Station from which values should be taken. This value will be automatically populated on first successful connection to weather station.

`Interval` - number of minutes defining how often data should be refreshed. This value will be automatically populated on initialization of quick application.

`AccessToken` - Allows to set own access token and bypass credentials authentication.

## Installation

To acquire required parameters, you need to go to Netatmo Connect site and create new application. Once that's done, you will be able to get client ID and client secret. To get refresh token, you need to use a Token generator (section below you get client id and client secret).
From generated token you need to use a Refresh Token value.
This should allow you to run quick application in your Fibaro Home Center device.

## Changing weather provider

To change default weather provider you need to go to Settings page and click General category. 
On displayed page you should see section called Main Sensors with Weather provider dropdown, that will let you pick OpenWeather Station as your new source of information.

To see changes in top bar, you need to refresh Home Center UI.

## Integration

This quick application integrates with other Netatmo dedicated quick apps for devices. It will automatically populate configuration to new virtual Netatmo devices.

## Support

Due to horrible user experience with Fibaro Marketplace, for better communication I recommend to contact with me through GitHub or create an issue in the repository.