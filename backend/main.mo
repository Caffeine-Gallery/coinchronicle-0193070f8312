import Float "mo:base/Float";

import Time "mo:base/Time";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Int "mo:base/Int";

actor {
    // Define the price record type
    public type PriceData = {
        price: Float;
        timestamp: Int;
    };

    // Store prices in a stable variable
    private stable var priceHistory : [PriceData] = [];
    private let buffer = Buffer.Buffer<PriceData>(0);

    // Initialize buffer with stable data
    private func initBuffer() {
        for (price in priceHistory.vals()) {
            buffer.add(price);
        };
    };
    initBuffer();

    // Add a new price
    public func addPrice(price: Float) : async () {
        let newPrice : PriceData = {
            price = price;
            timestamp = Time.now();
        };
        buffer.add(newPrice);
    };

    // Get all prices
    public query func getPrices() : async [PriceData] {
        return Buffer.toArray(buffer);
    };

    // Get latest price
    public query func getLatestPrice() : async ?PriceData {
        let size = buffer.size();
        if (size == 0) {
            return null;
        };
        ?buffer.get(size - 1);
    };

    // System functions for upgrades
    system func preupgrade() {
        priceHistory := Buffer.toArray(buffer);
    };

    system func postupgrade() {
        initBuffer();
    };
}
