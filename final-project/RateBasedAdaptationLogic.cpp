/*
 * RateBasedAdaptationLogic.cpp
 *****************************************************************************
 * Copyright (C) 2010 - 2011 Klagenfurt University
 *
 * Created on: Aug 10, 2010
 * Authors: Christopher Mueller <christopher.mueller@itec.uni-klu.ac.at>
 *          Christian Timmerer  <christian.timmerer@itec.uni-klu.ac.at>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif
#include <sys/time.h>
#include "../../vlc-dash_oml2.h"
#include "RateBasedAdaptationLogic.h"
#define OFF_PERIOD 4.0

extern oml_mps_t* g_oml_mps_vlc2;

using namespace dash::logic;
using namespace dash::xml;
using namespace dash::http;
using namespace dash::mpd;

struct timeval tv2;

RateBasedAdaptationLogic::RateBasedAdaptationLogic  (IMPDManager *mpdManager, stream_t *stream) :
                          AbstractAdaptationLogic   (mpdManager, stream),
                          mpdManager                (mpdManager),
                          count                     (0),
                          currentPeriod             (mpdManager->getFirstPeriod()),
                          width                     (0),
                          height                    (0),
                          policy                    (1),
                          buffersize                (30),
                          minbuffer                 (30),
			  maxbuffer		    (95)
{
    this->width      = var_InheritInteger(stream, "dash-prefwidth");
    this->height     = var_InheritInteger(stream, "dash-prefheight");
    this->policy     = var_InheritInteger(stream, "dash-policy");
    this->minbuffer  = var_InheritInteger(stream, "dash-minbuffer");
    this->buffersize = var_InheritInteger(stream, "dash-buffersize");
}

double SendTime = 0.0;
double ReceivedTime = 0.0;

Chunk*  RateBasedAdaptationLogic::getNextChunk()
{
    gettimeofday(&tv2, NULL);
    ReceivedTime = tv2.tv_sec + tv2.tv_usec/1000000.0;
    double DownloadTime = ReceivedTime - SentTime;
    if(DownloadTime <= OFF_PERIOD) //download interval setting to 2.0 sec
        msleep((OFF_PERIOD - DownloadTime)*1000000.0);

    if(this->mpdManager == NULL)
        return NULL;

    if(this->currentPeriod == NULL)
        return NULL;

    uint64_t bitrate = this->getBpsAvg();

    if(this->policy != 2)
    {
        // if(this->getBufferPercent() < MINBUFFER)
        if(this->getBufferPercent() < this->minbuffer )
        {
            if(this->policy == 1)
                bitrate = 0;
            else
                bitrate = this->getBpsAvg() / 2;
	}
//	if (this->getBufferPercent() > this->maxbuffer)
// 		msleep(OFF_PERIOD * 1000000.0);//off period
    }

    Representation *rep = this->mpdManager->getRepresentation(this->currentPeriod, bitrate, this->width, this->height);
    gettimeofday(&tv2,NULL);
    //fprintf(stderr,"Adaptation\t%f\t%lu\t%lu\n",  tv2.tv_sec + tv2.tv_usec/1000000.0, rep->getBandwidth(),bitrate);

    fprintf(stderr, "chosenRate_bps=%lu empiricalRate_bps=%lu decisionRate_bps=%lu buffer_percent=%lu\n",
           (int64_t) rep->getBandwidth(), (int64_t) this->getBpsAvg(), (int64_t) bitrate, (int64_t) this->getBufferPercent());

    oml_inject_dashRateAdaptation(g_oml_mps_vlc2->dashRateAdaptation,
       (int64_t) rep->getBandwidth(),
        (int64_t) this->getBpsAvg(), (int64_t) bitrate, (int64_t) this->getBufferPercent());


    if ( rep == NULL )
        return NULL;

    std::vector<Segment *> segments = this->mpdManager->getSegments(rep);

    if ( this->count == segments.size() )
    {
        this->currentPeriod = this->mpdManager->getNextPeriod(this->currentPeriod);
        this->count = 0;
        return this->getNextChunk();
    }

    if ( segments.size() > this->count )
    {
        Segment *seg = segments.at( this->count );
        Chunk *chunk = seg->toChunk();
        //In case of UrlTemplate, we must stay on the same segment.
        if ( seg->isSingleShot() == true )
            this->count++;
        seg->done();
	gettimeofday(&tv2,NULL);
	SentTime = tv2.tv_sec + tv2.tv_usec/1000000.0;
        return chunk;
    }
    return NULL;
}

const Representation *RateBasedAdaptationLogic::getCurrentRepresentation() const
{
    return this->mpdManager->getRepresentation( this->currentPeriod, this->getBpsAvg() );
}
