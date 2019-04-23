const P = require('parsimmon')

const input = '.:{([2 3]][[6 2]][[1 2])][([1 4]][[2 1])][([6 9])}:.'

const CrazyPointParser = P.createLanguage({
  Num: () => P.regexp(/[0-9]+/).map(Number),

  Point: (r) => P.seq(P.string('['), r.Num, P.string(' '), r.Num, P.string(']'))
    .map(([_open, x, _space, y, _close]) => [x, y]),

  Sep: () => P.string(']['),

  PointSet: (r) => P.seq(P.string('('), r.Point.sepBy(r.Sep), P.string(')'))
    .map(([_open, points, _close]) => points),

  PointSetArray: (r) => P.seq(P.string('.:{'), r.PointSet.sepBy(r.Sep), P.string('}:.'))
    .map(([_open, pointSets, _close]) => pointSets),


})

const a = '.:{([2 3]][[6 2]][[1 2])][([1 4]][[2 1])][([6 9])}:.'
console.log(CrazyPointParser.PointSetArray.tryParse(a))
