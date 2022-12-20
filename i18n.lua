--[[
Internationalization tool
@author ikubicki
]]
class 'i18n'

function i18n:new(langCode)
    self.phrases = phrases[langCode]
    return self
end

function i18n:get(key)
    if self.phrases[key] then
        return self.phrases[key]
    end
    return key
end

phrases = {
    pl = {
        ['search-devices'] = 'Szukaj urządzeń',
        ['searching-devices'] = 'Szukam...',
        ['refresh'] = 'Odśwież dane',
        ['refreshing'] = 'Odświeżam...',
        ['last-update'] = 'Ostatnia aktualizacja: %s',
        ['Temperature'] = 'Temperatura',
        ['Wind'] = 'Siła wiatru',
        ['Humidity'] = 'Wilgotność',
        ['Rain'] = 'Deszcz',
        ['search-row-station'] = '__ STACJA POGODOWA %s',
        ['search-row-station-modules'] = '__ Wykryto %d modułów',
        ['search-row-module'] = '____ MODUŁ %s (ID: %s, typ: %s)',
        ['search-row-module_types'] = '____ Typy danych: %s',
    },
    en = {
        ['search-devices'] = 'Search devices',
        ['searching-devices'] = 'Searching...',
        ['refresh'] = 'Update data',
        ['refreshing'] = 'Updating...',
        ['last-update'] = 'Last update at %s',
        ['Temperature'] = 'Temperature',
        ['Wind'] = 'Wind Strength',
        ['Humidity'] = 'Humidity',
        ['Rain'] = 'Rain',
        ['search-row-station'] = '__ WEATHER STATION %s',
        ['search-row-station-modules'] = '__ %d modules detected',
        ['search-row-module'] = '____ MODULE %s (ID: %s, type: %s)',
        ['search-row-module_types'] = '____ Data types: %s',
    },
    de = {
        ['search-devices'] = 'Geräte suchen',
        ['searching-devices'] = 'Suchen...',
        ['refresh'] = 'Aktualisieren',
        ['refreshing'] = 'Aktualisieren...',
        ['last-update'] = 'Letztes update: %s',
        ['Temperature'] = 'Temperatur',
        ['Wind'] = 'Windstärke',
        ['Humidity'] = 'Luftfeuchtigkeit',
        ['Rain'] = 'Regenfall',
        ['search-row-station'] = '__ WETTERSTATION %s',
        ['search-row-station-modules'] = '__ %d module erkannt',
        ['search-row-module'] = '____ MODULE %s (ID: %s, typ: %s)',
        ['search-row-module_types'] = '____ Datentypen: %s',
    }
}