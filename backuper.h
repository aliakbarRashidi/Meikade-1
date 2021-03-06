/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Meikade is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Meikade is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef BACKUPER_H
#define BACKUPER_H

#include <QObject>

class BackuperPrivate;
class Backuper : public QObject
{
    Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)
    Q_OBJECT
public:
    Backuper();
    ~Backuper();

    bool isActive() const;

public slots:
    void makeBackup();
    bool restore(const QString &path);

signals:
    void success();
    void failed();
    void activeChanged();

private slots:
    void process_successed();
    void process_failed();

private:
    BackuperPrivate *p;
};

class BackuperCorePrivate;
class BackuperCore : public QObject
{
    Q_OBJECT
public:
    BackuperCore();
    ~BackuperCore();

public slots:
    void makeBackup();
    void restore(const QString & path );

signals:
    void success();
    void failed();

private:
    BackuperCorePrivate *p;
};

#endif // BACKUPER_H
