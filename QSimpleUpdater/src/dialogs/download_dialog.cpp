/*
 * (C) Copyright 2014 Alex Spataru
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
#include <QMutex>
#include <QFileDialog>
#include <math.h>

#include "launcher.h"
#include "download_dialog.h"
#include "ui_download_dialog.h"

DownloadDialog::DownloadDialog (QWidget *parent) :
    QWidget(parent),
    ui (new Ui::DownloadDialog)
{

    // Setup the UI
    ui->setupUi (this);

    // Make the window look like a dialog
    QIcon _blank;
    setWindowIcon (_blank);
    setWindowModality (Qt::WindowModal);
    setWindowFlags (Qt::Dialog | Qt::CustomizeWindowHint | Qt::WindowTitleHint);

    // Connect SIGNALS/SLOTS
    connect (ui->stopButton, SIGNAL (clicked()),
             this,             SLOT (onCancelDownload()));

    // Initialize the network access manager
    m_manager = new QNetworkAccessManager (this);

    // Avoid SSL issues
    connect (m_manager, SIGNAL (sslErrors (QNetworkReply *, QList<QSslError>)),
             this,        SLOT (onIgnoreSslErrors (QNetworkReply *, QList<QSslError>)));
}

DownloadDialog::~DownloadDialog (void)
{
    delete ui;
}

void DownloadDialog::beginDownload (const QUrl& url)
{
    Q_ASSERT (!url.isEmpty());

    // Reset the UI
    ui->progressBar->setValue (0);
    ui->stopButton->setText (tr ("Stop"));
    ui->downloadLabel->setText (tr ("Downloading updates"));
    ui->timeLabel->setText (tr ("Time remaining") + ": " + tr ("unknown"));

    // Begin the download
    m_reply = m_manager->get (QNetworkRequest (url));
    m_start_time = QDateTime::currentDateTime().toTime_t();

    // Update the progress bar value automatically
    connect (m_reply, SIGNAL (downloadProgress (qint64, qint64)),
             this,      SLOT (onUpdateProgress (qint64, qint64)));

    // Write the file to the hard disk once the download is finished
    connect (m_reply, SIGNAL (finished()),
             this,      SLOT (onDownloadFinished()));

    // Show the dialog
    showNormal();
}

void DownloadDialog::onCancelDownload (void)
{
    if (!m_reply->isFinished())
    {
        QMessageBox _message;
        _message.setWindowTitle (tr ("Updater"));
        _message.setIcon (QMessageBox::Question);
        _message.setStandardButtons (QMessageBox::Yes | QMessageBox::No);
        _message.setText (tr ("Are you sure you want to cancel the download?"));

        if (_message.exec() == QMessageBox::Yes)
        {
            hide();
            m_reply->abort();
        }
    }

    else
        hide();
}

void DownloadDialog::onDownloadFinished (void)
{
    ui->stopButton->setText (tr ("Close"));
    ui->downloadLabel->setText (tr ("Download complete!"));
    ui->timeLabel->setText (tr ("The installer will open in a separate window..."));

    QByteArray data = m_reply->readAll();

    if (!data.isEmpty())
    {
        QStringList list = m_reply->url().toString().split ("/");

//        QFile file (QFileDialog::getSaveFileName(this,
//                                                 tr("Save File"),
//                                                 QDir::homePath()+ "/" + list.at (list.count() - 1)));
        QDir dir(QCoreApplication::applicationDirPath()+ "/updates/");
        if (!dir.exists()) {
            dir.mkpath(".");
        }
        QString new_file = QCoreApplication::applicationDirPath()+ "/updates/" + list.at (list.count() - 1);
        QFile file(new_file);
        QMutex _mutex;

        if (file.open (QIODevice::WriteOnly))
        {
            _mutex.lock();
            file.write (data);
            m_path = file.fileName();
            file.close();
            _mutex.unlock();
        }

        if(execUpdater())
            qApp->quit();
        else
            this->close();
    }
}

void DownloadDialog::onUpdateProgress (qint64 received, qint64 total)
{
    // We know the size of the download, so we can calculate the progress....
    if (total > 0 && received > 0)
    {
        ui->progressBar->setMinimum (0);
        ui->progressBar->setMaximum (100);

        int _progress = (int) ((received * 100) / total);
        ui->progressBar->setValue (_progress);

        QString _total_string;
        QString _received_string;

        float _total = total;
        float _received = received;

        if (_total < 1024)
            _total_string = tr ("%1 bytes").arg (_total);

        else if (_total < 1024 * 1024)
        {
            _total = roundNumber (_total / 1024);
            _total_string = tr ("%1 KB").arg (_total);
        }

        else
        {
            _total = roundNumber (_total / (1024 * 1024));
            _total_string = tr ("%1 MB").arg (_total);
        }

        if (_received < 1024)
            _received_string = tr ("%1 bytes").arg (_received);

        else if (received < 1024 * 1024)
        {
            _received = roundNumber (_received / 1024);
            _received_string = tr ("%1 KB").arg (_received);
        }

        else
        {
            _received = roundNumber (_received / (1024 * 1024));
            _received_string = tr ("%1 MB").arg (_received);
        }

        ui->downloadLabel->setText (tr ("Downloading updates") + " (" + _received_string + " " + tr ("of") + " " + _total_string + ")");

        uint _diff = QDateTime::currentDateTime().toTime_t() - m_start_time;

        if (_diff > 0)
        {
            QString _time_string;
            float _time_remaining = total / (received / _diff);

            if (_time_remaining > 7200)
            {
                _time_remaining /= 3600;
                _time_string = tr ("About %1 hours").arg (int (_time_remaining + 0.5));
            }

            else if (_time_remaining > 60)
            {
                _time_remaining /= 60;
                _time_string = tr ("About %1 minutes").arg (int (_time_remaining + 0.5));
            }

            else if (_time_remaining <= 60)
                _time_string = tr ("%1 seconds").arg (int (_time_remaining + 0.5));

            ui->timeLabel->setText (tr ("Time remaining") + ": " + _time_string);
        }
    }

    // We do not know the size of the download, so we avoid scaring the shit out
    // of the user
    else
    {
        ui->progressBar->setValue (-1);
        ui->progressBar->setMinimum (0);
        ui->progressBar->setMaximum (0);
        ui->downloadLabel->setText (tr ("Downloading updates"));
        ui->timeLabel->setText (tr ("Time remaining") + ": " + tr ("Unknown"));
    }
}

void DownloadDialog::onIgnoreSslErrors (QNetworkReply *reply,
                                      const QList<QSslError>& error)
{
#ifndef Q_OS_IOS
    reply->ignoreSslErrors (error);
#else
    Q_UNUSED (reply);
    Q_UNUSED (error);
#endif
}

float DownloadDialog::roundNumber (const float& input)
{
    return roundf (input * 100) / 100;
}
