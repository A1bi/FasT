barcode = {
  format: 'PKBarcodeFormatQR',
  message: ticket.signed_info(medium: :passbook),
  messageEncoding: 'utf-8',
  altText: ticket.number
}

json.merge!(
  formatVersion: 1,
  description: "Ticket für das Theaterstück „#{ticket.date.event.name}“",
  organizationName: 'Freilichtbühne am schiefen Turm',
  passTypeIdentifier: @type_id,
  serialNumber: @serial,
  authenticationToken: @auth_token,
  groupingIdentifier: ticket.order.number.to_s,
  voided: ticket.cancelled?,
  teamIdentifier: 'V48L6BF6M3',
  webServiceURL: api_passbook_root_url,
  relevantDate: ticket.date.date.iso8601,
  backgroundColor: rgb_color(colors[:background]),
  foregroundColor: rgb_color(colors[:foreground]),
  labelColor: rgb_color(colors[:label]),
  locations: [
    {
      latitude: location[0],
      longitude: location[1]
    }
  ],
  barcode: barcode,
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
        value: ticket.date.event.location,
        changeMessage: 'Der Veranstaltungsort wurde verlegt nach „%@“.'
      },
      {
        key: 'opens',
        label: 'Einlass',
        value: ticket.date.door_time.iso8601,
        timeStyle: 'PKDateStyleShort'
      },
      {
        key: 'ticket_type',
        label: 'Kategorie',
        value: ticket.type.name,
        changeMessage: 'Die Kategorie Ihres Tickets wurde geändert auf „%@“.'
      }
    ]
  )

  secondary_fields = []

  if ticket.date.event.seating.plan?
    if ticket.block.entrance.present?
      secondary_fields << {
        key: 'entrance',
        label: 'Eingang',
        value: ticket.block.entrance,
        textAlignment: 'PKTextAlignmentLeft',
        changeMessage: 'Der aktualisierte Eingang zu Ihrem Sitzplatz lautet %@.'
      }
    end

    if ticket.block.name.present?
      secondary_fields << {
        key: 'block',
        label: 'Block',
        value: ticket.block.name,
        changeMessage: 'Ihr Sitzplatz befindet sich nun in Block %@.'
      }
    end

    if ticket.seat.row.present?
      secondary_fields << {
        key: 'row',
        label: 'Reihe',
        value: ticket.seat.row,
        changeMessage: 'Ihr Sitzplatz befindet sich nun in Reihe %@.'
      }
    end

    secondary_fields << {
      key: 'seat',
      label: 'Sitzplatz',
      value: ticket.seat.number,
      textAlignment: 'PKTextAlignmentLeft',
      changeMessage: 'Ihre neue Sitznummer lautet %@.'
    }

  else
    secondary_fields << {
      key: 'seat',
      label: 'Sitzplatz',
      value: 'Freie Platzwahl'
    }
  end

  json.merge!(secondaryFields: secondary_fields)

  back_fields = [
    {
      key: 'overviewUrl',
      label: 'Ticket umbuchen oder stornieren',
      value: "Auf unserer <a href=\"#{order_overview_url(ticket.order.signed_info(authenticated: true))}\">Website</a> haben Sie die Möglichkeit, Ihre Tickets umzubuchen oder zu stornieren."
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

  if location_address.present?
    back_fields << {
      key: 'locationAddress',
      label: 'Adresse des Veranstaltungsortes',
      attributedValue: "<a href=\"http://maps.apple.com/?ll=#{location[0]},#{location[1]}&q=#{url_encode(local_assigns[:location_label])}\">#{location_address}</a>. Eine Karte mit Parkmöglichkeiten finden Sie <a href=\"#{info_url(ticket.event.slug)}\">hier</a>.",
      value: location_address
    }
  end

  json.merge!(backFields: back_fields)
end
