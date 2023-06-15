# frozen_string_literal: true

parkings = [
  {
    loc: [7.142834, 50.230012],
    desc: 'hinterm Busbahnhof'
  },
  {
    loc: [7.138999, 50.23086],
    title: 'Großer Parkplatz',
    desc: 'Klostergasse'
  },
  {
    loc: [7.143714, 50.232184],
    desc: 'nahe der Alten Schule'
  },
  {
    loc: [7.143382, 50.23286],
    desc: 'gegenüber Brasserie „Alt Esch“'
  },
  {
    loc: [7.141955, 50.231441],
    desc: 'direkt an der Koblenzer Straße'
  },
  {
    loc: [7.139995, 50.230981],
    title: 'Großer Parkplatz',
    desc: 'hinter der Sparkasse'
  },
  {
    loc: [7.13739, 50.23529]
  },
  {
    loc: [7.13651, 50.23480]
  },
  {
    loc: [7.13592, 50.23415]
  }
]

json.markers do
  json.array! parkings do |parking|
    json.loc parking[:loc]
    json.icon 'parking'
    json.title parking.fetch(:title, 'Parkplätze')
    json.desc parking[:desc]
  end

  json.array! [@event.location] do |location|
    json.loc location.coordinates.to_a.reverse
    json.title location.name
    json.desc location.address
  end
end
