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

#include "meikade.h"
#include "meikadedatabase.h"
#include "userdata.h"
#include "threadeddatabase.h"
#include "threadedfilesystem.h"
#include "backuper.h"
#include "listobject.h"
#include "hashobject.h"
#include "systeminfo.h"
#include "meikade_macros.h"
#include "sialantools/sialandevices.h"
#include "sialantools/sialanquickview.h"

#ifdef Q_OS_ANDROID
#include "sialantools/sialanjavalayer.h"
#endif

#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QCloseEvent>
#include <QGuiApplication>
#include <QQuickItem>
#include <QScreen>
#include <QDesktopServices>
#include <QClipboard>
#include <QUrl>
#include <QDir>
#include <QTimer>
#include <QDateTime>
#include <QTranslator>
#include <QLocale>
#include <qmath.h>

QString translate_0 = "0";
QString translate_1 = "1";
QString translate_2 = "2";
QString translate_3 = "3";
QString translate_4 = "4";
QString translate_5 = "5";
QString translate_6 = "6";
QString translate_7 = "7";
QString translate_8 = "8";
QString translate_9 = "9";

QString translateNumbers( QString input )
{
    input.replace("0",translate_0);
    input.replace("1",translate_1);
    input.replace("2",translate_2);
    input.replace("3",translate_3);
    input.replace("4",translate_4);
    input.replace("5",translate_5);
    input.replace("6",translate_6);
    input.replace("7",translate_7);
    input.replace("8",translate_8);
    input.replace("9",translate_9);
    return input;
}

class MeikadePrivate
{
public:
    SialanQuickView *viewer;
    MeikadeDatabase *poem_db;
    UserData *user_db;
    ThreadedDatabase *threaded_db;
    ThreadedFileSystem *threaded_fs;
    Backuper *backuper;
    SystemInfo *system;

    SialanDevices *devices;
#ifdef Q_OS_ANDROID
    SialanJavaLayer *java_layer;
#endif

    bool close;
    int hide_keyboard_timer;

    QTranslator *translator;

    QHash<QString,QVariant> languages;
    QHash<QString,QLocale> locales;
    QString language;

    QString poem_font;
};

Meikade::Meikade(QObject *parent) :
    QObject(parent)
{
    p = new MeikadePrivate;
    p->viewer = 0;
    p->hide_keyboard_timer = 0;
    p->translator = new QTranslator(this);
    p->poem_font = settings()->value("General/PoemFont","DroidNaskh-Regular").toString();
#ifdef Q_OS_ANDROID
    p->close  = false;
#else
    p->close  = false;
#endif

    QDir().mkpath(HOME_PATH);
    init_languages();
}

bool Meikade::fileExists(const QString &f)
{
    if( f.isEmpty() )
        return false;

    if( f[0] == '/' )
        return QFile::exists(f);
    else
        return QFile::exists( ":/qml/Meikade/" + f );
}

QChar Meikade::convertChar(const QChar &ch)
{
    QString num = ch;
    switch( num.toInt() )
    {
    case 0: return QString::fromUtf8("۰").at(0);
    case 1: return QString::fromUtf8("۱").at(0);
    case 2: return QString::fromUtf8("۲").at(0);
    case 3: return QString::fromUtf8("۳").at(0);
    case 4: return QString::fromUtf8("۴").at(0);
    case 5: return QString::fromUtf8("۵").at(0);
    case 6: return QString::fromUtf8("۶").at(0);
    case 7: return QString::fromUtf8("۷").at(0);
    case 8: return QString::fromUtf8("۸").at(0);
    case 9: return QString::fromUtf8("۹").at(0);
    }

    return QChar();
}

QString Meikade::numberToArabicString(int number)
{
    QString res;
    const QString & txt = QString::number(number);
    for( int i=0; i<txt.length(); i++ )
        res += convertChar(txt[i]);

    return res;
}

QStringList Meikade::findBackups()
{
    QString path = BACKUP_PATH;

    QStringList files = QDir(path).entryList( QStringList() << "*.mkdb", QDir::Files, QDir::Size );
    for( int i=0; i<files.count(); i++ )
        files[i] = path + "/" + files[i];

    return files;
}

QString Meikade::fileName(const QString &path)
{
    return QFileInfo(path).baseName();
}

QString Meikade::fileSuffix(const QString &path)
{
    return QFileInfo(path).suffix().toLower();
}

QStringList Meikade::availableFonts()
{
    return QStringList() << "DroidNaskh-Regular" << "IranNastaliq";
}

qreal Meikade::fontPointScale(const QString &fontName)
{
    if( fontName == "DroidNaskh-Regular" )
        return 1;
    else
    if( fontName == "IranNastaliq" )
        return 1.3;
    else
        return 1;
}

QStringList Meikade::languages()
{
    QStringList res = p->languages.keys();
    res.sort();
    return res;
}

void Meikade::setCurrentLanguage(const QString &lang)
{
    if( p->language == lang )
        return;

    QGuiApplication::removeTranslator(p->translator);
    p->translator->load(p->languages.value(lang).toString(),"languages");
    QGuiApplication::installTranslator(p->translator);
    p->language = lang;

    settings()->setValue("General/Language",lang);

    translate_0 = Meikade::tr("0");
    translate_1 = Meikade::tr("1");
    translate_2 = Meikade::tr("2");
    translate_3 = Meikade::tr("3");
    translate_4 = Meikade::tr("4");
    translate_5 = Meikade::tr("5");
    translate_6 = Meikade::tr("6");
    translate_7 = Meikade::tr("7");
    translate_8 = Meikade::tr("8");
    translate_9 = Meikade::tr("9");

    emit currentLanguageChanged();
    emit languageDirectionChanged();
}

QString Meikade::currentLanguage() const
{
    return p->language;
}

QString Meikade::resourcePathAbs()
{
#ifdef Q_OS_ANDROID
    return "assets:";
#else
    static QString *resourcePath = 0;
    if( !resourcePath )
    {
#ifdef Q_OS_MAC
        QFileInfo inf(QCoreApplication::applicationDirPath() + "/../Resources");
        resourcePath = new QString(inf.filePath());
#else
        QFileInfo inf(QCoreApplication::applicationDirPath()+"/../share/meikade");
        if( inf.exists() )
            resourcePath = new QString(inf.filePath());
        else
            resourcePath = new QString(QCoreApplication::applicationDirPath());
#endif
    }
    return *resourcePath + "/";
#endif
}

QString Meikade::resourcePath()
{
#ifdef Q_OS_ANDROID
    return resourcePathAbs();
#else
#ifdef Q_OS_WIN
    return "file:///" + resourcePathAbs();
#else
    return "file://" + resourcePathAbs();
#endif
#endif
}

Qt::LayoutDirection Meikade::languageDirection()
{
    return p->locales.value(currentLanguage()).textDirection();
}

qint64 Meikade::mSecsSinceEpoch() const
{
    return QDateTime::currentDateTime().toMSecsSinceEpoch();
}

void Meikade::removeFile(const QString &path)
{
    QFile::remove(path);
}

void Meikade::setProperty(QObject *obj, const QString &property, const QVariant &v)
{
    if( !obj || property.isEmpty() )
        return;

    obj->setProperty( property.toUtf8(), v );
}

QVariant Meikade::property(QObject *obj, const QString &property)
{
    if( !obj || property.isEmpty() )
        return QVariant();

    return obj->property(property.toUtf8());
}

void Meikade::setAnimations(bool stt)
{
    if( animations() == stt )
        return;

    settings()->setValue("General/animations",stt);
    emit animationsChanged();
}

bool Meikade::animations() const
{
    static bool def = p->devices->isIOS() || ( p->system->cpuCores() > 1 && p->system->cpuFreq()/1000 >= 1024 );
    return settings()->value("General/animations",def).toBool();
}

void Meikade::setPoemsFont(const QString &name)
{
    if( p->poem_font == name )
        return;

    p->poem_font = name;
    settings()->setValue("General/PoemFont",p->poem_font);
    emit poemsFontChanged();
}

QString Meikade::poemsFont() const
{
    return p->poem_font;
}

QSettings *Meikade::settings()
{
    static QSettings *stngs = new QSettings( HOME_PATH + "/config.ini", QSettings::IniFormat );
    return stngs;
}

void Meikade::start()
{
    if( p->viewer )
        return;

#ifdef Q_OS_ANDROID
    p->java_layer = SialanJavaLayer::instance();
#endif

    p->threaded_fs = new ThreadedFileSystem(this);
    p->poem_db = new MeikadeDatabase(p->threaded_fs,this);
    p->user_db = new UserData(this);
    p->threaded_db = new ThreadedDatabase(p->poem_db,this);
    p->backuper = new Backuper();
    p->system = new SystemInfo(this);
    p->devices = new SialanDevices(this);

    p->viewer = new SialanQuickView(
#ifndef Q_OS_ANDROID
                        SialanQuickView::AllExceptLogger
#else
                        SialanQuickView::AllComponents
#endif
                );
    p->viewer->installEventFilter(this);
    p->viewer->engine()->rootContext()->setContextProperty( "Meikade" , this );
    p->viewer->engine()->rootContext()->setContextProperty( "Database", p->poem_db  );
    p->viewer->engine()->rootContext()->setContextProperty( "UserData", p->user_db  );
    p->viewer->engine()->rootContext()->setContextProperty( "Backuper", p->backuper );
    p->viewer->engine()->rootContext()->setContextProperty( "System"  , p->system   );
    p->viewer->engine()->rootContext()->setContextProperty( "ThreadedFileSystem", p->threaded_fs );
    p->viewer->engine()->rootContext()->setContextProperty( "ThreadedDatabase"  , p->threaded_db );
    p->viewer->setSource(QStringLiteral("qrc:///qml/Meikade/main.qml"));
    p->viewer->setIcon( QIcon(":/qml/Meikade/icons/meikade.png") );
    p->viewer->show();
}

void Meikade::close()
{
    p->close = true;
    p->viewer->close();
}

void Meikade::timer(int interval, QObject *obj, const QString &member)
{
    QTimer::singleShot(interval, obj, QString(SLOT() + member + "()").toStdString().c_str() );
}

bool Meikade::eventFilter(QObject *o, QEvent *e)
{
    if( o == p->viewer )
    {
        switch( static_cast<int>(e->type()) )
        {
        case QEvent::Close:
        {
            QCloseEvent *ce = static_cast<QCloseEvent*>(e);
            if( p->close || p->devices->isDesktop() )
                ce->accept();
            else
            {
                ce->ignore();
                emit closeRequest();
            }
        }
            break;
        }
    }

    return QObject::eventFilter(o,e);
}

void Meikade::init_languages()
{
    QDir dir(TRANSLATIONS_PATH);
    QStringList languages = dir.entryList( QDir::Files );
    if( !languages.contains("lang-en.qm") )
        languages.prepend("lang-en.qm");

    for( int i=0 ; i<languages.size() ; i++ )
     {
         QString locale_str = languages[i];
             locale_str.truncate( locale_str.lastIndexOf('.') );
             locale_str.remove( 0, locale_str.indexOf('-') + 1 );

         QLocale locale(locale_str);

         QString  lang = QLocale::languageToString(locale.language());
         QVariant data = TRANSLATIONS_PATH + "/" + languages[i];

         p->languages.insert( lang, data );
         p->locales.insert( lang , locale );

         if( lang == settings()->value("General/Language","Persian").toString() )
             setCurrentLanguage( lang );
    }
}

Meikade::~Meikade()
{
    if( p->viewer )
        delete p->viewer;
    if( p->backuper )
        delete p->backuper;

    delete p;
}
