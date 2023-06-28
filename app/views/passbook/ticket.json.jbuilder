# frozen_string_literal: true

barcode = {
  format: 'PKBarcodeFormatQR',
  message: ticket.signed_info(medium: :passbook),
  messageEncoding: 'utf-8',
  altText: ticket.number
}

json.merge!(
  formatVersion: 1,
  description: "Ticket für das Theaterstück „#{ticket.event.name}“",
  organizationName: 'TheaterKultur Kaisersesch',
  passTypeIdentifier: @type_id,
  serialNumber: @serial,
  authenticationToken: @auth_token,
  groupingIdentifier: ticket.order.number.to_s,
  voided: ticket.cancelled?,
  teamIdentifier: @team_id,
  webServiceURL: api_passbook_root_url,
  logoText: ticket.event.name,
  relevantDate: ticket.date.date.iso8601,
  backgroundColor: 'rgb(255, 255, 255)',
  foregroundColor: 'rgb(31, 32, 52)',
  labelColor: 'rgb(255, 92, 92)',
  locations: [
    {
      latitude: ticket.event.location.coordinates.x,
      longitude: ticket.event.location.coordinates.y
    }
  ],
  barcode:,
  barcodes: [barcode]
)

json.eventTicket do
  json.merge!(
    primaryFields: [
      {
        key: 'date',
        label: 'Beginn',
        value: ticket.date.date.iso8601,
        dateStyle: 'PKDateStyleFull',
        timeStyle: 'PKDateStyleShort',
        changeMessage: 'Ihr Ticket wurde auf folgendes Datum umgebucht: %@'
      }
    ],
    auxiliaryFields: [
      {
        key: 'location',
        label: 'Veranstaltungsort',
        value: "#{ticket.event.location.name}\n#{ticket.event.location.address}",
        changeMessage: 'Der Veranstaltungsort wurde verlegt nach „%@“.'
      },
      {
        key: 'ticket_type',
        label: 'Kategorie',
        value: ticket.type.name,
        changeMessage: 'Die Kategorie Ihres Tickets wurde geändert auf „%@“.'
      }
    ]
  )

  secondary_fields = [
    {
      key: 'admission_time',
      label: 'Einlass',
      value: ticket.date.admission_time.iso8601,
      timeStyle: 'PKDateStyleShort'
    }
  ]

  if ticket.seat.present?
    if ticket.block.entrance.present?
      secondary_fields << {
        key: 'entrance',
        label: 'Eingang',
        value: ticket.block.entrance,
        textAlignment: 'PKTextAlignmentLeft',
        changeMessage: 'Der aktualisierte Eingang zu Ihrem Sitzplatz lautet %@.'
      }
    end

    secondary_fields << {
      key: 'seat',
      label: 'Sitzplatz',
      value: ticket.seat.full_number,
      textAlignment: 'PKTextAlignmentLeft',
      changeMessage: 'Ihr neuer Sitzplatz lautet %@.'
    }

    if ticket.seat.row.present?
      secondary_fields << {
        key: 'row',
        label: 'Reihe',
        value: ticket.seat.row,
        changeMessage: 'Ihr Sitzplatz befindet sich nun in Reihe %@.'
      }
    end

  elsif ticket.event.covid19?
    secondary_fields << {
      key: 'seat',
      label: 'Sitzplatz',
      value: 'wird vor Ort mitgeteilt'
    }

  else
    secondary_fields << {
      key: 'seat',
      label: 'Sitzplatz',
      value: 'Freie Platzwahl'
    }
  end

  json.merge!(secondaryFields: secondary_fields)

  signed_info = ticket.order.signed_info(authenticated: true)
  back_fields = [
    {
      key: 'overviewUrl',
      label: 'Ticket umbuchen oder stornieren',
      value: 'Auf unserer Website haben Sie die Möglichkeit, Ihre Tickets ' \
             "<a href=\"#{order_overview_url(signed_info)}\">umzubuchen oder zu stornieren</a>."
    },
    {
      key: 'hotline',
      label: 'Hotline',
      value: '+49 2653 282709'
    },
    {
      key: 'order',
      label: 'Ticketnummer',
      value: ticket.number
    }
  ]

  coordinates = ticket.event.location.coordinates.to_a.join(',')
  maps_url = "http://maps.apple.com/?ll=#{coordinates}&q=#{url_encode(ticket.event.location.name)}"
  back_fields << {
    key: 'locationAddress',
    label: 'Adresse des Veranstaltungsortes',
    attributedValue: "<a href=\"#{maps_url}\">#{ticket.event.location.address}</a>. " \
                     'Eine Karte mit Parkmöglichkeiten finden Sie ' \
                     "<a href=\"#{event_url(ticket.event.slug, anchor: 'map')}\">hier</a>.",
    value: ticket.event.location.address
  }

  json.merge!(backFields: back_fields)
end
