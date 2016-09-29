
airportQueryCache = {}



ajaxError = (cb) ->
    return (xmlHttpRequest, textStatus, exception) ->
        console.error textStatus, exception, xmlHttpRequest
        if cb then cb()



makeAirportInput = (selector) ->


    conform = (airportList, searchTerm) ->
        return airportList
            .filter (a) ->
                ['airportCode', 'airportName', 'cityCode', 'cityName'].some (attr) ->
                    a[attr].match new RegExp "^#{searchTerm}", 'i'
            .map (a) ->
                "#{a.airportCode} #{a.airportName} (#{a.cityName}, #{a.countryName})"


    source = ({term}, response) ->
        queryTerm = term[...2]

        cache = airportQueryCache[queryTerm]
        if cache
            return response conform cache, term

        $.ajax
            url: "/airports?q=#{queryTerm}"
            dataType: 'json'
            error: ajaxError -> response []
            success: (data) ->
                airportQueryCache[queryTerm] = data
                response conform data, term


    $(selector).autocomplete
        delay: 0
        minLength: 2
        source: source





$ ->
    $('#departure-date').datepicker()
    makeAirportInput '#from'
    makeAirportInput '#to'








