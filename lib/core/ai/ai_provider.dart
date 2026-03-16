enum AiProvider {
  gemini,
  openai,
}

AiProvider aiProviderFromString(String value) {
  if (value == AiProvider.openai.name) return AiProvider.openai;
  return AiProvider.gemini;
}
