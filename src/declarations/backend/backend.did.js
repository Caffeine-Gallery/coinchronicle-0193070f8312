export const idlFactory = ({ IDL }) => {
  const PriceData = IDL.Record({
    'timestamp' : IDL.Int,
    'price' : IDL.Float64,
  });
  return IDL.Service({
    'addPrice' : IDL.Func([IDL.Float64], [], []),
    'getLatestPrice' : IDL.Func([], [IDL.Opt(PriceData)], ['query']),
    'getPrices' : IDL.Func([], [IDL.Vec(PriceData)], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
