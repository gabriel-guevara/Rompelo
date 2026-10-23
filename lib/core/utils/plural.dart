/// "1 ronda" / "3 rondas": plural sencillo en español para textos de la UI.
///
/// Si algún día la app se traduce, esto se reemplaza por `intl` (`Intl.plural`).
String plural(int count, String singular, String pluralForm) =>
    '$count ${count == 1 ? singular : pluralForm}';
