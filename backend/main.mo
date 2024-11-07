import Float "mo:base/Float";

import Time "mo:base/Time";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Int "mo:base/Int";

actor {
    public type PriceData = {
        price: Float;
        timestamp: Int;
    };

    private stable var priceHistory : [PriceData] = [];
    private let buffer = Buffer.Buffer<PriceData>(0);

    private func initBuffer() {
        for (price in priceHistory.vals()) {
            buffer.add(price);
        };
    };
    initBuffer();

    public func addPrice(price: Float) : async () {
        let newPrice : PriceData = {
            price = price;
            timestamp = Time.now();
        };
        buffer.add(newPrice);
    };

    public query func getPrices() : async [PriceData] {
        return Buffer.toArray(buffer);
    };

    public query func getLastMonthPrices() : async [PriceData] {
        let now = Time.now();
        let oneMonthNanos = 30 * 24 * 60 * 60 * 1_000_000_000;
        let monthAgo = now - oneMonthNanos;
        
        let filtered = Buffer.Buffer<PriceData>(0);
        for (price in buffer.vals()) {
            if (price.timestamp >= monthAgo) {
                filtered.add(price);
            };
        };
        return Buffer.toArray(filtered);
    };

    public query func getLatestPrice() : async ?PriceData {
        let size = buffer.size();
        if (size == 0) {
            return null;
        };
        ?buffer.get(size - 1);
    };

    system func preupgrade() {
        priceHistory := Buffer.toArray(buffer);
    };

    system func postupgrade() {
        initBuffer();
    };
}
