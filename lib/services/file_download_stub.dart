// LabTrack - file download, phone build. See file_download.dart.

/// Saving a file is a web portal feature; the phone app reports that it
/// cannot, so the caller can say so.
bool downloadTextFile(String fileName, String text,
        {String mimeType = 'text/plain'}) =>
    false;
