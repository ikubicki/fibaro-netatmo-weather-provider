# Netatmo weather provider

An alternative to YR weather provider, that is default weather provider for HC3.

This quick application creates weather device only.

Data updates every 5 minutes by default.

## Configuration

`Client ID` - Netatmo client ID

`Client Secret` - Netatmo client secret

`Username` - Netatmo username

`Password` - Netatmo password

### Optional values

`Device ID` - identifier of Netatmo Weather Station from which values should be taken. This value will be automatically populated on first successful connection to weather station.

`Refresh Interval` - number of minutes defining how often data should be refreshed. This value will be automatically populated on initialization of quick application.

## Changing weather provider

To change default weather provider you need to go to Settings page and click General category. 
On displayed page you should see section called Main Sensors with Weather provider dropdown, that will let you pick OpenWeather Station as your new source of information.

To see changes in top bar, you need to refresh Home Center UI.

## Integration

This quick application integrates with other Netatmo dedicated quick apps for devices. It will automatically populate configuration to new virtual Netatmo devices.