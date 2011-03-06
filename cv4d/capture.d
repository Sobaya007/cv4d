﻿module cv4d.capture;

import cv4d.opencv.all;
import cv4d.image, cv4d._internal.misc;

/*******************************************************************************
 * ビデオ入出力クラス
 * 
 * See_Also: HighGUI リファレンス マニュアルのビデオ入出力（Video I/O）
 */
class Capture
{
protected:
	
	
	/***************************************************************************
	 * OpenCVで扱うことのできる生のCvCapture*
	 */
	CvCapture* m_Capture;
	invariant()
	{
		assert(m_Capture);
	}
	
	
	/***************************************************************************
	 * 内部的にであれば何もしないコンストラクタを呼び出すことが可能
	 * 
	 * ただし、必ず m_Capture は何らかの画像で初期化される必要があり、
	 * デストラクタが呼ばれる際には、確実に m_Capture を null とするか、
	 * cvReleaseCapture によって解放されてもよい画像を指定しておくこと
	 */
	this()
	{
		
	}
	
	
	/***************************************************************************
	 * プロパティの取得/設定を行う
	 */
	double property(int property_id)
	{
		return cvGetCaptureProperty(m_Capture, property_id);
	}
	
	
	///ditto
	void property(int property_id, double value)
	{
		return cvSetCaptureProperty(m_Capture, property_id, value);
	}
	
	
private:
	
	
	static class CapturedImage: Image
	{
		this(in IplImage* captured)
		{
			// ホントは未定義だけど…どうしろと
			m_Image = cast(IplImage*)captured;
		}
		~this()
		{
			// ホントは未定義だけど…どうしろと
			m_Image = null;
		}
	}
	
	
public:
	
	
	/***************************************************************************
	 * OpenCVでの操作用
	 */
	CvCapture* handle()
	{
		return m_Capture;
	}
	///ditto
	const(CvCapture)* handle() const
	{
		return m_Capture;
	}
	/***************************************************************************
	 * カメラからのビデオキャプチャを初期化する
	 * 
	 * カメラからビデオストリームを読み込むために、CvCapture 構造体を確保して
	 * 初期化する。
	 * Windows では、次の二つのカメラインタフェースが利用できる：
	 * - Video for Windows（VFW）
	 * - Matrox Imaging Library（MIL）
	 * Linux では，次の二つのカメラインタフェースが利用できる：
	 * - Video for Linux（V4L）
	 * - FireWire（IEEE1394）． 
	 */
	this(int cameraid)
	{
		m_Capture = cvCreateCameraCapture(cameraid);
	}
	
	
	/***************************************************************************
	 * ファイルからのビデオキャプチャを初期化する
	 * 
	 * 指定されたファイルからビデオストリームを読み込むために
	 * CvCapture 構造体を確保して初期化する．
	 */
	this(char[] filename)
	{
		m_Capture = cvCreateFileCapture(toMBSz(filename));
	}
	
	
	/***************************************************************************
	 * デストラクタ
	 */
	~this()
	{
		if (m_Capture) cvReleaseCapture(&m_Capture);
		m_Capture = null;
	}
	
	
	/***************************************************************************
	 * カメラやファイルからフレームを取り出す
	 * 
	 * 関数 cvGrabFrame は，カメラやファイルからフレームを取り出す．
	 * 取り出されたフレームは内部的に保存される．この関数の目的は，
	 * 高速にフレームを取り出すことである．これは複数台のカメラから
	 * 同時に読み込むような場合に，カメラ間の同期のために重要となる．
	 * 取り出されたフレームは，（カメラ/ドライバによって定義された）
	 * 圧縮フォーマット の形で保存されるので，
	 * これらがそのまま公開されることはない．
	 * 取り出されたフレームをユーザ側で利用するためには，
	 * cvRetrieveFrame を用いるべきである．
	 */
	int grabFrame()
	{
		return cvGrabFrame(m_Capture);
	}
	
	
	/***************************************************************************
	 * cvGrabFrame によって取り出された画像を取得する
	 * 
	 * grabFrame 関数によって取り出された画像を取り出す。
	 */
	const(Image) retrieveFrame(int streamIdx = 0)
	{
		return new const(CapturedImage)(cvRetrieveFrame(m_Capture, streamIdx));
	}
	
	
	/***************************************************************************
	 * 
	 * カメラやビデオファイルから一つのフレームを取り出し、それを展開して返す。
	 * この関数は、単純に grabFrame と retrieveFrame をまとめて呼び出している
	 * だけである。
	 */
	const(Image) queryFrame()
	{
		return retrieveFrame(grabFrame());
	}
	
	
	/***************************************************************************
	 * 現在時刻[ms]
	 * 
	 * @property setter/getter
	 * ビデオファイル中の現在の位置[ms]
	 * あるいはビデオキャプチャのタイムスタンプ値
	 */
	final double posMsec()
	{
		return property(CV_CAP_PROP_POS_MSEC);
	}
	
	
	///ditto
	final void posMsec(double value)
	{
		property(CV_CAP_PROP_POS_MSEC, value);
	}
	
	
	/***************************************************************************
	 * 次にデコード/キャプチャされるフレームのインデックス。
	 * 
	 * @property setter/getter
	 * 0から始まる
	 */
	final double posFrames()
	{
		return property(CV_CAP_PROP_POS_FRAMES);
	}
	
	
	///ditto
	final void posFrames(double value)
	{
		property(CV_CAP_PROP_POS_FRAMES, value);
	}
	
	
	/***************************************************************************
	 * ビデオファイル内の相対的な位置[0, 1]
	 * 
	 * @property setter/getter
	 * 0 - ファイルの開始位置
	 * 1 - ファイルの終了位置
	 * setterの場合ビデオファイルのみ
	 */
	final double aviRatio()
	{
		return property(CV_CAP_PROP_POS_AVI_RATIO);
	}
	
	
	///ditto
	final void aviRatio(double value)
	{
		property(CV_CAP_PROP_POS_AVI_RATIO, value);
	}
	
	
	/***************************************************************************
	 * ビデオストリーム中のフレームの幅[px]
	 * 
	 * @property setter/getter
	 * setterの場合カメラのみ
	 */
	final double width()
	{
		return property(CV_CAP_PROP_FRAME_WIDTH);
	}
	
	
	///ditto
	final void width(double value)
	{
		property(CV_CAP_PROP_FRAME_WIDTH, value);
	}
	
	
	/***************************************************************************
	 * ビデオストリーム中のフレームの高さ[px]
	 * 
	 * @property setter/getter
	 * setterの場合カメラのみ
	 */
	final double height()
	{
		return property(CV_CAP_PROP_FRAME_HEIGHT);
	}
	
	
	///ditto
	final void height(double value)
	{
		property(CV_CAP_PROP_FRAME_HEIGHT, value);
	}
	
	
	/***************************************************************************
	 * サイズ
	 */
	final CvSize size()
	{
		return cvSize(cast(int)width, cast(int)height);
	}
	
	
	///ditto
	final void size(CvSize sz)
	{
		width = cast(double)sz.width;
		height = cast(double)sz.height;
	}
	
	/***************************************************************************
	 * フレームレート
	 * 
	 * @property setter/getter
	 * setterの場合カメラのみ
	 */
	final double fps()
	{
		return property(CV_CAP_PROP_FPS);
	}
	
	
	///ditto
	final void fps(double value)
	{
		property(CV_CAP_PROP_FPS, value);
	}
	
	
	/***************************************************************************
	 * コーデックを表す 4 文字
	 * 
	 * @property setter/getter
	 * setterの場合カメラのみ
	 */
	final double fourcc()
	{
		return property(CV_CAP_PROP_FOURCC);
	}
	
	
	///ditto
	final void fourcc(double value)
	{
		property(CV_CAP_PROP_FOURCC, value);
	}
	
	
	/***************************************************************************
	 * ビデオファイル中のフレーム数
	 * 
	 * @property setter/getter
	 * ビデオのみ
	 */
	final double frameCount()
	{
		return property(CV_CAP_PROP_FRAME_COUNT);
	}
	
	
	///ditto
	final void frameCount(double value)
	{
		property(CV_CAP_PROP_FRAME_COUNT, value);
	}
	
	
	/***************************************************************************
	 * 明度
	 */
	final double brightness()
	{
		return property(CV_CAP_PROP_BRIGHTNESS);
	}
	
	
	///ditto
	final void brightness(double value)
	{
		property(CV_CAP_PROP_BRIGHTNESS, value);
	}
	
	
	/***************************************************************************
	 * コントラスト
	 */
	final double contrast()
	{
		return property(CV_CAP_PROP_CONTRAST);
	}
	
	
	///ditto
	final void contrast(double value)
	{
		property(CV_CAP_PROP_CONTRAST, value);
	}
	
	
	/***************************************************************************
	 * 彩度
	 */
	final double saturation()
	{
		return property(CV_CAP_PROP_SATURATION);
	}
	
	
	///ditto
	final void saturation(double value)
	{
		property(CV_CAP_PROP_SATURATION, value);
	}
	
	
	/***************************************************************************
	 * 色相
	 */
	final double hue()
	{
		return property(CV_CAP_PROP_HUE);
	}
	
	
	///ditto
	final void hue(double value)
	{
		property(CV_CAP_PROP_HUE, value);
	}
	
	
	/***************************************************************************
	 * ゲイン
	 */
	final double gain()
	{
		return property(CV_CAP_PROP_GAIN);
	}
	
	
	///ditto
	final void gain(double value)
	{
		property(CV_CAP_PROP_GAIN, value);
	}
	
	
	/***************************************************************************
	 * モード
	 */
	final double mode()
	{
		return property(CV_CAP_PROP_MODE);
	}
	
	
	///ditto
	final void mode(double value)
	{
		property(CV_CAP_PROP_MODE, value);
	}
	
	
	/***************************************************************************
	 * ホワイトバランス
	 */
	final double white()
	{
		return property(CV_CAP_PROP_WHITE_BALANCE);
	}
	
	
	///ditto
	final void white(double value)
	{
		property(CV_CAP_PROP_WHITE_BALANCE, value);
	}
	
	
	/***************************************************************************
	 * 露出
	 */
	final double exposure()
	{
		return property(CV_CAP_PROP_EXPOSURE);
	}
	
	
	///ditto
	final void exposure(double value)
	{
		property(CV_CAP_PROP_EXPOSURE, value);
	}
	
	
	/+
	
	なぜかLinuxでは利用不可能だった。とりあえずコメントアウトしておく
	
	/***************************************************************************
	 * キャプチャの種類
	 * 
	 * たとえば CV_CAP_V4W や CV_CAP_UNICAP など。 CV_CAP_ANY として知られるもの
	 */
	int domain()
	{
		return cvGetCaptureDomain(m_Capture);
	}
	+/
}

enum FourCC
{
	PROMPT  = CV_FOURCC_PROMPT,
	DEFAULT = CV_FOURCC_DEFAULT,
	
	ANIM    = CV_FOURCC('A','N','I','M'),
	AUR2    = CV_FOURCC('A','U','R','2'),
	AURA    = CV_FOURCC('A','U','R','A'),
	BT20    = CV_FOURCC('B','T','2','0'),
	BTCV    = CV_FOURCC('B','T','C','V'),
	CC12    = CV_FOURCC('C','C','1','2'),
	CDVC    = CV_FOURCC('C','D','V','C'),
	CHAM    = CV_FOURCC('C','H','A','M'),
	CPLA    = CV_FOURCC('C','P','L','A'),
	CVID    = CV_FOURCC('C','V','I','D'),
	CWLT    = CV_FOURCC('C','W','L','T'),
	DUCK    = CV_FOURCC('D','U','C','K'),
	DVE2    = CV_FOURCC('D','V','E','2'),
	DXT1    = CV_FOURCC('D','X','T','1'),
	DXT2    = CV_FOURCC('D','X','T','2'),
	DXT3    = CV_FOURCC('D','X','T','3'),
	DXT4    = CV_FOURCC('D','X','T','4'),
	DXT5    = CV_FOURCC('D','X','T','5'),
	DXTC    = CV_FOURCC('D','X','T','C'),
	FLJP    = CV_FOURCC('F','L','J','P'),
	GWLT    = CV_FOURCC('G','W','L','T'),
	H260    = CV_FOURCC('H','2','6','0'),
	H261    = CV_FOURCC('H','2','6','1'),
	H262    = CV_FOURCC('H','2','6','2'),
	H263    = CV_FOURCC('H','2','6','3'),
	H264    = CV_FOURCC('H','2','6','4'),
	H265    = CV_FOURCC('H','2','6','5'),
	H266    = CV_FOURCC('H','2','6','6'),
	H267    = CV_FOURCC('H','2','6','7'),
	H268    = CV_FOURCC('H','2','6','8'),
	H269    = CV_FOURCC('H','2','6','9'),
	I263    = CV_FOURCC('I','2','6','3'),
	I420    = CV_FOURCC('I','4','2','0'),
	ICLB    = CV_FOURCC('I','C','L','B'),
	ILVC    = CV_FOURCC('I','L','V','C'),
	ILVR    = CV_FOURCC('I','L','V','R'),
	IRAW    = CV_FOURCC('I','R','A','W'),
	IV30    = CV_FOURCC('I','V','3','0'),
	IV31    = CV_FOURCC('I','V','3','1'),
	IV32    = CV_FOURCC('I','V','3','2'),
	IV33    = CV_FOURCC('I','V','3','3'),
	IV34    = CV_FOURCC('I','V','3','4'),
	IV35    = CV_FOURCC('I','V','3','5'),
	IV36    = CV_FOURCC('I','V','3','6'),
	IV37    = CV_FOURCC('I','V','3','7'),
	IV38    = CV_FOURCC('I','V','3','8'),
	IV39    = CV_FOURCC('I','V','3','9'),
	IV40    = CV_FOURCC('I','V','4','0'),
	IV41    = CV_FOURCC('I','V','4','1'),
	IV42    = CV_FOURCC('I','V','4','2'),
	IV43    = CV_FOURCC('I','V','4','3'),
	IV44    = CV_FOURCC('I','V','4','4'),
	IV45    = CV_FOURCC('I','V','4','5'),
	IV46    = CV_FOURCC('I','V','4','6'),
	IV47    = CV_FOURCC('I','V','4','7'),
	IV48    = CV_FOURCC('I','V','4','8'),
	IV49    = CV_FOURCC('I','V','4','9'),
	IV50    = CV_FOURCC('I','V','5','0'),
	MP42    = CV_FOURCC('M','P','4','2'),
	MPEG    = CV_FOURCC('M','P','E','G'),
	MRCA    = CV_FOURCC('M','R','C','A'),
	MRLE    = CV_FOURCC('M','R','L','E'),
	MSVC    = CV_FOURCC('M','S','V','C'),
	NTN1    = CV_FOURCC('N','T','N','1'),
	RGBT    = CV_FOURCC('R','G','B','T'),
	RT21    = CV_FOURCC('R','T','2','1'),
	SDCC    = CV_FOURCC('S','D','C','C'),
	SFMC    = CV_FOURCC('S','F','M','C'),
	SMSC    = CV_FOURCC('S','M','S','C'),
	SMSD    = CV_FOURCC('S','M','S','D'),
	SPLC    = CV_FOURCC('S','P','L','C'),
	SQZ2    = CV_FOURCC('S','Q','Z','2'),
	SV10    = CV_FOURCC('S','V','1','0'),
	TLMS    = CV_FOURCC('T','L','M','S'),
	TLST    = CV_FOURCC('T','L','S','T'),
	TM20    = CV_FOURCC('T','M','2','0'),
	TMIC    = CV_FOURCC('T','M','I','C'),
	TMOT    = CV_FOURCC('T','M','O','T'),
	TR20    = CV_FOURCC('T','R','2','0'),
	V422    = CV_FOURCC('V','4','2','2'),
	V655    = CV_FOURCC('V','6','5','5'),
	VCR1    = CV_FOURCC('V','C','R','1'),
	VIVO    = CV_FOURCC('V','I','V','O'),
	VIXL    = CV_FOURCC('V','I','X','L'),
	VLV1    = CV_FOURCC('V','L','V','1'),
	WBVC    = CV_FOURCC('W','B','V','C'),
	XLV0    = CV_FOURCC('X','L','V','0'),
	YC12    = CV_FOURCC('Y','C','1','2'),
	YUV8    = CV_FOURCC('Y','U','V','8'),
	YUV9    = CV_FOURCC('Y','U','V','9'),
	YUYV    = CV_FOURCC('Y','U','Y','V'),
	ZPEG    = CV_FOURCC('Z','P','E','G'),
	
	YUY2    = CV_FOURCC('Y','U','Y','2'),
	DIV3    = CV_FOURCC('D','I','V','3'),
	DIB     = CV_FOURCC('D','I','B',' '),
	IYUV    = CV_FOURCC('I','Y','U','V'),
	MPG4    = CV_FOURCC('M','P','G','4'),
	MP43    = CV_FOURCC('M','P','4','3'),
	DIVX    = CV_FOURCC('D','I','V','X'),
	THEO    = CV_FOURCC('T','H','E','O'),
}

/*******************************************************************************
 * 録画クラス
 */
class Recoder
{
protected:
	CvVideoWriter* m_VideoWriter;
public:
	/***************************************************************************
	 * コンストラクタ
	 */
	this(in char[] filename, CvSize size = cvSize(640, 480),
	     double fps = 30.0, FourCC fourcc = FourCC.DEFAULT,
	     int is_color = 1)
	{
		m_VideoWriter = cvCreateVideoWriter(
			toMBSz(filename), fourcc, fps, size, is_color);
	}
	
	// デストラクタ
	~this()
	{
		if (m_VideoWriter) cvReleaseVideoWriter(&m_VideoWriter);
	}
	
	
	/***************************************************************************
	 * フレームを追加する
	 */
	void opCall(Image img)
	{
		cvWriteFrame(m_VideoWriter, img.handle);
	}
}

/*******************************************************************************
 * 録画クラス
 * 
 * 経過時間を指定することで足りない部分には画像を挿入する。
 * また、異なるサイズでもリサンプル処理をした画像を使用することで自動的に
 * サイズ合わせを行う
 */
class SmartRecoder: Recoder
{
protected:
	double tmNow;
	double tmRec;
	double interval;
	Image image;
public:
	
	/***************************************************************************
	 * コンストラクタ
	 * 
	 * filenameのファイルに対して、sizeの大きさの画像を1秒間にfps枚間隔で
	 * fourccのコーデックを使い録画する
	 */
	this(in char[] filename, CvSize size = cvSize(640, 480),
	     double fps = 30.0, FourCC fourcc = FourCC.DEFAULT,
	     int color = 1)
	{
		interval = 1/fps;
		image = new Image(size);
		super(filename, size, fps, fourcc, color);
	}
	
	/***************************************************************************
	 * 現在時刻[秒]を設定/取得
	 */
	void time(double sec)
	in
	{
		assert(tmNow < sec);
	}
	body
	{
		tmNow = sec;
	}
	
	
	///ditto
	double time()
	{
		return tmNow;
	}
	
	
	/***************************************************************************
	 * 最終録画時刻[秒]を設定/取得
	 */
	double recTime()
	{
		return tmRec;
	}
	
	
	/***************************************************************************
	 * サイズ
	 */
	CvSize size()
	{
		return image.size;
	}
	
	
	/***************************************************************************
	 * 録画
	 */
	override void opCall(Image img)
	in
	{
		assert(tmNow <>= 0);
	}
	body
	{
		if (tmRec !<>= 0)
		{
			tmRec = tmNow;
		}
		while (tmRec+interval < tmNow)
		{
			super.opCall(image);
			tmRec += interval;
		}
		image.fixedResample(img);
		super.opCall(image);
		tmRec += interval;
	}
	
	
	/***************************************************************************
	 * 時刻を指定して録画
	 */
	void opCall(double tm, Image img)
	{
		tmNow = tm;
		opCall(img);
	}
}