/*
 * (C) Copyright 2014 Alex Spataru
 * (C) Copyright 2016 Alex Makarov
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 */

#ifndef QSIMPLEUPDATER_H
#define QSIMPLEUPDATER_H

#include <QObject>
#include <QUrl>

class QSslError;
class QNetworkReply;
class QNetworkAccessManager;
class DownloadDialog;
class ProgressDialog;

class QSimpleUpdater : public QObject {
    Q_OBJECT

public:
    QSimpleUpdater (QObject *parent = 0);
    ~QSimpleUpdater ();

    QString changeLog() const;
    QString latestVersion() const;
    QString installedVersion() const;

    bool silent() const;
    bool newerVersionAvailable() const;

    void checkForUpdates (void);
    void openDownloadLink (void);
    void downloadLatestVersion (void);

public slots:
    void setSilent (bool silent);
    void setDownloadUrl (const QString& url);
    void setReferenceUrl (const QString& url);
    void setChangelogUrl (const QString& url);
    void setShowNewestVersionMessage (bool show);
    void setShowUpdateAvailableMessage (bool show);
    void setApplicationVersion (const QString& version);

signals:
    /*! \fn QSimpleUpdater::checkingFinished (void)
     * This signal is triggered when the updater system finishes downloading
     * and proccessing the version data and changelog data.
     */
    void checkingFinished (void);

private slots:
    void cancel (void);
    void showErrorMessage (void);
    void onCheckingFinished (void);
    void checkDownloadedVersion (QNetworkReply *reply);
    void processDownloadedChangelog (QNetworkReply *reply);
    void ignoreSslErrors (QNetworkReply *reply, const QList<QSslError>& error);

private:
    QString m_changelog;
    QString m_latest_version;
    QString m_installed_version;
    QNetworkAccessManager *m_manager;

    QUrl m_download_url;
    QUrl m_reference_url;
    QUrl m_changelog_url;

    bool m_silent;
    bool m_show_newest_version;
    bool m_show_update_available;
    bool m_new_version_available;

    DownloadDialog *m_downloadDialog;
    ProgressDialog *m_progressDialog;
};

#endif  // QSIMPLEUPDATER_H
