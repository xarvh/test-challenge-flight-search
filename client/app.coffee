#
# Helpers
#
flashError = (errorMessage) ->
    console.error '[error]', errorMessage



ajaxError = (cb) ->
    return (xmlHttpRequest, textStatus, exception) ->
        console.error textStatus, exception, xmlHttpRequest
        if cb then cb textStatus



#
# Airports
#
airportQueryCache = {}


getAllCachedAirports = ->
    list = []
    for k, v of airportQueryCache
        list.push v...
    return list

airportToDisplayString = (a) ->
    "#{a.airportCode} #{a.airportName} (#{a.cityName}, #{a.countryName})"



#
# Airport selection
#
makeAirportInput = (selector) ->


    conform = (airportList, searchTerm) ->
        return airportList
            .filter (a) ->
                ['airportCode', 'airportName', 'cityCode', 'cityName'].some (attr) ->
                    a[attr].match new RegExp "^#{searchTerm}", 'i'
            .map airportToDisplayString


    source = ({term}, response) ->
        queryTerm = term[...2]

        cache = airportQueryCache[queryTerm]
        if cache
            return response conform cache, term

        $.getJSON
            url: "/airports?q=#{queryTerm}"
            error: ajaxError -> response []
            success: (data) ->
                airportQueryCache[queryTerm] = data
                response conform data, term


    $(selector).autocomplete
        delay: 0
        minLength: 2
        source: source



#
# Search
#
getFormData = ->

    allAirports = getAllCachedAirports()
    airportCodeByDisplayName = _(allAirports).keyBy(airportToDisplayString).mapValues('airportCode').value()


    from = airportCodeByDisplayName[$('#from').val()]
    if not from
        return error: "Origin field should contain a valid airport"


    to = airportCodeByDisplayName[$('#to').val()]
    if not to
        return error: "Destination field should contain a valid airport"


    date = $('#departure-date').val()
    if not date
        return error: "Please specify departure date"

    return { from, to, date }



runSearch = ->
    {from, to, date, error} = getFormData()
    if error
        return flashError error

    dateRangeStart = moment(date, 'YY-MM-DD').subtract(2, 'days')
    if dateRangeStart < moment() then dateRangeStart = moment()

    [0...5].forEach (offset) ->
        date = dateRangeStart.clone().add(offset, 'days').format('YYYY-MM-DD')
        initSearchResults offset, date
        $.getJSON
            url: "/search?#{$.param {from, to, date}}"
            error: ajaxError flashError
            success: (results) ->
                displaySearchResult offset, date, results



#
# Search Results
#
initSearchResults = (offset, date) ->
    $("li.offset-#{offset} a")
        .text(date)
        .click ->
            selectNav offset

    $('.results-container')
        .show()



selectNav = (offset) ->
    $(".results-container .nav-pill").removeClass('active')
    $(".results-container .offset-#{offset}").addClass('active')

    $(".results").hide()
    $(".results.offset-#{offset}").show()



displaySearchResult = (offset, date, results) ->

    flightToHtml = (flight) ->
        """
        <tr>
            <td>#{flight.airline.name}</td>
            <td>#{moment.duration(flight.durationMin, 'minutes').humanize()}</td>
            <td>#{flight.airline.code} #{flight.flightNum}</td>
            <td>$#{flight.price}</td>
            <td>#{flight.start.dateTime} #{flight.start.timeZone}</td>
            <td>#{flight.finish.dateTime} #{flight.finish.timeZone}</td>
        </tr>
        """

    listItems =
        _(results)
            .sortBy('price')
            .take(10)
            .map(flightToHtml)
            .join('\n')

    $(".results.offset-#{offset}")
        .html """
            <table class='table'>
                <thead>
                    <tr>
                        <th>Airline</th>
                        <th>Duration</th>
                        <th>Flight</th>
                        <th>Price</th>
                        <th>Departure</th>
                        <th>Arrival</th>
                    </tr>
                </thead>
                #{listItems}
            </table>"
            """



#
# Main
#
$ ->
    makeAirportInput '#from'
    makeAirportInput '#to'

    $('#departure-date')
        .val moment().add(2, 'days').format('YY-MM-DD')
        .datepicker
            dateFormat: 'y-mm-dd'
            minDate: 0
            defaultDate: 1

    $('#search').click (event) ->
        event.preventDefault()
        runSearch()
