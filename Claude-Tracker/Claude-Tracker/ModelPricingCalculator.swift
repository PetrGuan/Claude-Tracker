//
//  ModelPricingCalculator.swift
//  Claude-Tracker
//
//  Created by AI on 2026-02-16.
//  Model-specific pricing calculator for different Claude models
//

import Foundation

/// Token counts structure
struct TokenCounts {
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int

    var total: Int {
        inputTokens + outputTokens + cacheCreationTokens + cacheReadTokens
    }
}

/// Model-specific pricing for Claude models
struct ModelPricing {
    let inputCostPerMillion: Double
    let outputCostPerMillion: Double
    let cacheCreationCostPerMillion: Double
    let cacheReadCostPerMillion: Double

    /// Calculate cost for given token counts
    func calculateCost(tokens: TokenCounts) -> Double {
        let inputCost = Double(tokens.inputTokens) / 1_000_000.0 * inputCostPerMillion
        let outputCost = Double(tokens.outputTokens) / 1_000_000.0 * outputCostPerMillion
        let cacheCreationCost = Double(tokens.cacheCreationTokens) / 1_000_000.0 * cacheCreationCostPerMillion
        let cacheReadCost = Double(tokens.cacheReadTokens) / 1_000_000.0 * cacheReadCostPerMillion

        return inputCost + outputCost + cacheCreationCost + cacheReadCost
    }
}

/// Model pricing calculator following Anthropic's pricing structure
class ModelPricingCalculator {

    // MARK: - Predefined Model Pricing

    /// Claude 3 Opus pricing (most expensive)
    static let opus3Pricing = ModelPricing(
        inputCostPerMillion: 15.0,
        outputCostPerMillion: 75.0,
        cacheCreationCostPerMillion: 18.75,  // 1.25x input
        cacheReadCostPerMillion: 1.5          // 0.1x input
    )

    /// Claude 4 Opus pricing
    static let opus4Pricing = ModelPricing(
        inputCostPerMillion: 15.0,
        outputCostPerMillion: 75.0,
        cacheCreationCostPerMillion: 18.75,
        cacheReadCostPerMillion: 1.5
    )

    /// Claude 3.5 Sonnet pricing (default)
    static let sonnet35Pricing = ModelPricing(
        inputCostPerMillion: 3.0,
        outputCostPerMillion: 15.0,
        cacheCreationCostPerMillion: 3.75,    // 1.25x input
        cacheReadCostPerMillion: 0.3          // 0.1x input
    )

    /// Claude 4 Sonnet pricing
    static let sonnet4Pricing = ModelPricing(
        inputCostPerMillion: 3.0,
        outputCostPerMillion: 15.0,
        cacheCreationCostPerMillion: 3.75,
        cacheReadCostPerMillion: 0.3
    )

    /// Claude 3 Sonnet pricing
    static let sonnet3Pricing = ModelPricing(
        inputCostPerMillion: 3.0,
        outputCostPerMillion: 15.0,
        cacheCreationCostPerMillion: 3.75,
        cacheReadCostPerMillion: 0.3
    )

    /// Claude 3.5 Haiku pricing (cheapest)
    static let haiku35Pricing = ModelPricing(
        inputCostPerMillion: 0.25,
        outputCostPerMillion: 1.25,
        cacheCreationCostPerMillion: 0.30,    // 1.25x input (but min 0.3)
        cacheReadCostPerMillion: 0.03         // 0.1x input
    )

    /// Claude 3 Haiku pricing
    static let haiku3Pricing = ModelPricing(
        inputCostPerMillion: 0.25,
        outputCostPerMillion: 1.25,
        cacheCreationCostPerMillion: 0.30,
        cacheReadCostPerMillion: 0.03
    )

    // MARK: - Pricing Map

    /// Map of model names to their pricing
    private static let pricingMap: [String: ModelPricing] = [
        "claude-3-opus": opus3Pricing,
        "claude-opus-4": opus4Pricing,
        "claude-opus-4-20250514": opus4Pricing,
        "claude-3-5-sonnet": sonnet35Pricing,
        "claude-3-sonnet": sonnet3Pricing,
        "claude-sonnet-4": sonnet4Pricing,
        "claude-sonnet-4-20250514": sonnet4Pricing,
        "claude-3-5-haiku": haiku35Pricing,
        "claude-3-haiku": haiku3Pricing
    ]

    // MARK: - Public Methods

    /// Normalize model name to standard format
    static func normalizeModelName(_ model: String) -> String {
        guard !model.isEmpty else { return "" }

        let modelLower = model.lowercased()

        // Claude 4 models
        if modelLower.contains("opus-4") || modelLower.contains("claude-opus-4") {
            return "claude-opus-4"
        }
        if modelLower.contains("sonnet-4") || modelLower.contains("claude-sonnet-4") {
            return "claude-sonnet-4"
        }

        // Claude 3 models
        if modelLower.contains("opus") {
            return "claude-3-opus"
        }
        if modelLower.contains("sonnet") {
            if modelLower.contains("3.5") || modelLower.contains("3-5") {
                return "claude-3-5-sonnet"
            }
            return "claude-3-sonnet"
        }
        if modelLower.contains("haiku") {
            if modelLower.contains("3.5") || modelLower.contains("3-5") {
                return "claude-3-5-haiku"
            }
            return "claude-3-haiku"
        }

        return model
    }

    /// Get pricing for a specific model (with fallback to Sonnet 3.5)
    static func getPricing(for model: String) -> ModelPricing {
        let normalized = normalizeModelName(model)
        return pricingMap[normalized] ?? sonnet35Pricing  // Default to Sonnet 3.5 pricing
    }

    /// Calculate cost for a model with token counts
    static func calculateCost(model: String, tokens: TokenCounts) -> Double {
        let pricing = getPricing(for: model)
        return pricing.calculateCost(tokens: tokens)
    }

    /// Calculate cost for a model with individual token values
    static func calculateCost(
        model: String,
        inputTokens: Int,
        outputTokens: Int,
        cacheCreationTokens: Int,
        cacheReadTokens: Int
    ) -> Double {
        let tokens = TokenCounts(
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: cacheCreationTokens,
            cacheReadTokens: cacheReadTokens
        )
        return calculateCost(model: model, tokens: tokens)
    }

    /// Get human-readable display name for model
    static func getDisplayName(for model: String) -> String {
        let normalized = normalizeModelName(model)

        switch normalized {
        case "claude-3-opus":
            return "Claude 3 Opus"
        case "claude-opus-4", "claude-opus-4-20250514":
            return "Claude 4 Opus"
        case "claude-3-5-sonnet":
            return "Claude 3.5 Sonnet"
        case "claude-3-sonnet":
            return "Claude 3 Sonnet"
        case "claude-sonnet-4", "claude-sonnet-4-20250514":
            return "Claude 4 Sonnet"
        case "claude-3-5-haiku":
            return "Claude 3.5 Haiku"
        case "claude-3-haiku":
            return "Claude 3 Haiku"
        default:
            return model
        }
    }
}
