<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>
	<xsl:template match="/transmissions">
		<xsl:variable name="channelTerritoryCode" select="/transmissions/ES_TRANSMISSION[1]/
			tx_channel/ESP_CHANNEL/territory/ESP_TERRITORY/@printcode"/>
		<transmissionschedule xmlns="http://www.sbstv.se" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<exportinformation>
				<createdby>
					<xsl:value-of select="exportinformation/@username"/>
				</createdby>
				<timestamp>
					<xsl:apply-templates select="exportinformation/timestamp/ESP_TIMEINSTANT" mode="datetime"/>
				</timestamp>
				<schedule-start>
					<xsl:for-each select="ES_TRANSMISSION">
						<xsl:sort select="tx_starttimepoint/ESP_TIMEINSTANT/@broadcastdateindays" data-type="number" order="ascending"/>
						<xsl:sort select="tx_starttimepoint/ESP_TIMEINSTANT/@broadcastdurationinseconds" data-type="number" order="ascending"/>
						<xsl:if test="position() = 1">
							<xsl:apply-templates select="tx_starttimepoint/ESP_TIMEINSTANT" mode="datetime"/>
						</xsl:if>
					</xsl:for-each>
				</schedule-start>
				<schedule-end>
					<xsl:for-each select="ES_TRANSMISSION">
						<xsl:sort select="tx_endtimepoint/ESP_TIMEINSTANT/@broadcastdateindays" data-type="number" order="descending"/>
						<xsl:sort select="tx_endtimepoint/ESP_TIMEINSTANT/@broadcastdurationinseconds" data-type="number" order="descending"/>
						<xsl:if test="position() = 1">
							<xsl:apply-templates select="tx_endtimepoint/ESP_TIMEINSTANT" mode="datetime"/>
						</xsl:if>
					</xsl:for-each>
				</schedule-end>
			</exportinformation>
			<broadcastchannel>
				<xsl:value-of select="concat(ES_TRANSMISSION/tx_channel/ESP_CHANNEL/popupLookups/POPUPLOOKUP
					[@interface = 'Astra'][@attribute = 'Channel']/@translation1, '/', ES_TRANSMISSION/tx_channel/ESP_CHANNEL/@name)"/>
			</broadcastchannel>
			<broadcastdate>
				<xsl:value-of select="concat(ES_TRANSMISSION/tx_date/ESP_DATE/@date, 'T00:00:00.000')"/>
			</broadcastdate>
			<transmissions>
				<xsl:for-each select="ES_TRANSMISSION">
					<xsl:sort select="tx_starttimepoint/ESP_TIMEINSTANT/@broadcastdateindays" data-type="number" order="ascending"/>
					<xsl:sort select="tx_starttimepoint/ESP_TIMEINSTANT/@broadcastdurationinseconds" data-type="number" order="ascending"/>
					<transmission>
						<announcedtime>
							<xsl:choose>
								<xsl:when test="tx_announcedtimepoint/ESP_TIMEINSTANT">
									<xsl:apply-templates select="tx_announcedtimepoint/ESP_TIMEINSTANT" mode="displaytime"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="tx_starttimepoint/ESP_TIMEINSTANT" mode="displaytime"/>
								</xsl:otherwise>
							</xsl:choose>
						</announcedtime>
						<xsl:variable name="livetx">
							<xsl:value-of select="@tx_islive"/>
						</xsl:variable>
						<islive>
							<xsl:call-template name="truefalse2yesno">
								<xsl:with-param name="value" select="$livetx"/>
							</xsl:call-template>
						</islive>
						<transmission-oid>
							<xsl:value-of select="@tx_external_reference"/>
						</transmission-oid>
						<xsl:if test="tx_product/ES_PRODUCT">
							<xsl:variable name="poid">
								<xsl:choose>
									<xsl:when test="tx_product/ES_PRODUCT/@prd_external_reference">
										<xsl:value-of select="tx_product/ES_PRODUCT/@prd_external_reference"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="tx_product/ES_PRODUCT/@oid"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="ptitle">
								<xsl:choose>
									<xsl:when test="tx_product/ES_PRODUCT/p_episode_series/ES_PRODUCT">
										<xsl:call-template name="getTitle">
											<xsl:with-param name="channelTerritoryCode" select="$channelTerritoryCode"/>
											<xsl:with-param name="titles" select="tx_product/ES_PRODUCT/p_episode_series/ES_PRODUCT/p_product_producttitles"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="getTitle">
											<xsl:with-param name="channelTerritoryCode" select="$channelTerritoryCode"/>
											<xsl:with-param name="titles" select="tx_product/ES_PRODUCT/p_product_producttitles"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="pfirsttx">
								<xsl:variable name="firsttx">
									<xsl:variable name="txdateindays">
										<xsl:value-of select="tx_date/ESP_DATE/@dateindays"/>
									</xsl:variable>
									<xsl:for-each select="tx_product/ES_PRODUCT/p_product_productversions/
										ES_PRODUCT/p_product_plannedtransmissions/ES_TRANSMISSION">
										<xsl:sort select="tx_date/ESP_DATE/@dateindays" data-type="number" order="ascending"/>
										<xsl:if test="position() = 1">
											<xsl:choose>
												<xsl:when test="tx_date/ESP_DATE/@dateindays = $txdateindays">
													<xsl:text>yes</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>no</xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="string-length($firsttx) &gt; 0">
										<xsl:value-of select="$firsttx"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>no</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="(string-length($ptitle) &gt; 0) and (string-length($poid) &gt; 0) and (string-length($pfirsttx) &gt; 0)">
								<productinformation>
									<program-oid>
										<xsl:value-of select="$poid"/>
									</program-oid>
									<xsl:variable name="soid">
										<xsl:choose>
											<xsl:when test="tx_product/ES_PRODUCT/p_episode_series/ES_PRODUCT/@prd_external_reference">
												<xsl:value-of select="tx_product/ES_PRODUCT/p_episode_series/ES_PRODUCT/@prd_external_reference"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="tx_product/ES_PRODUCT/p_episode_series/ES_PRODUCT/@oid"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<series-oid>
										<xsl:choose>
											<xsl:when test="string-length($soid) &gt; 0">
												<xsl:value-of select="$soid"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$poid"/>
											</xsl:otherwise>
										</xsl:choose>
									</series-oid>
									<title>
										<xsl:value-of select="$ptitle"/>
									</title>
									<xsl:if test="(tx_product/ES_PRODUCT/@p_episode_internalepisodenumber) 
										and (tx_product/ES_PRODUCT/@p_product_masterseriesyear) 
										and (number(tx_product/ES_PRODUCT/@p_product_masterseriesyear))">
										<episodenumber>
											<xsl:value-of select="tx_product/ES_PRODUCT/@p_episode_internalepisodenumber"/>
										</episodenumber>
										<seasonnumber>
											<xsl:value-of select="tx_product/ES_PRODUCT/@p_product_masterseriesyear"/>
										</seasonnumber>
									</xsl:if>
									<isfirsttransmission>
										<xsl:value-of select="$pfirsttx"/>
									</isfirsttransmission>
									
									<pgrating>
										<xsl:choose>
											<xsl:when test="tx_certification/ESP_PROGRAMCERTIFICATION">
												<xsl:value-of select="tx_certification/ESP_PROGRAMCERTIFICATION/@name"/>
											</xsl:when>
											<xsl:otherwise>Null</xsl:otherwise>
										</xsl:choose>
									</pgrating>
									<ratingcontent1>
										<xsl:choose>
											<xsl:when
												test="tx_product/ES_PRODUCT/p_product_regionalcertifications/ES_WONREGIONALPROGRAMCERTIFICATION/
												rpc_parentalRatingContent1/ESP_PARENTALRATINGCONTENT/@printcode">
												<xsl:value-of
													select="tx_product/ES_PRODUCT/p_product_regionalcertifications/ES_WONREGIONALPROGRAMCERTIFICATION/
													rpc_parentalRatingContent1/ESP_PARENTALRATINGCONTENT/@printcode"
												/>
											</xsl:when>
											<xsl:otherwise/>
										</xsl:choose>
									</ratingcontent1>
									<ratingcontent2>
										<xsl:choose>
											<xsl:when
												test="tx_product/ES_PRODUCT/p_product_regionalcertifications/ES_WONREGIONALPROGRAMCERTIFICATION/
												rpc_parentalRatingContent2/ESP_PARENTALRATINGCONTENT/@printcode">
												<xsl:value-of
													select="tx_product/ES_PRODUCT/p_product_regionalcertifications/ES_WONREGIONALPROGRAMCERTIFICATION/
													rpc_parentalRatingContent2/ESP_PARENTALRATINGCONTENT/@printcode"
												/>
											</xsl:when>
											<xsl:otherwise/>
										</xsl:choose>
									</ratingcontent2>
									<ttv>
										<xsl:choose>
											<xsl:when test="tx_product/ES_PRODUCT/p_program_subtitlingmode/ESP_SUBTITLINGMODE/@name">
												<xsl:value-of select="tx_product/ES_PRODUCT/p_program_subtitlingmode/ESP_SUBTITLINGMODE/@name"/>
											</xsl:when>
											<xsl:otherwise>Null</xsl:otherwise>
										</xsl:choose>
									</ttv>
									<webcontentavailable>
										<xsl:text>no</xsl:text>
									</webcontentavailable>
									<productplacement>
										<xsl:choose>
											<xsl:when test="tx_product/ES_PRODUCT/@hasProductPlacement = 'true'">Yes</xsl:when>
											<xsl:otherwise>No</xsl:otherwise>
										</xsl:choose>
									</productplacement>
									<logo>
										<xsl:choose>
											<xsl:when
												test="tx_txtype/ESP_TRANSMISSIONTYPE/popupLookups/POPUPLOOKUP
												[@attribute = 'Inline Logo (Transmission type)']/@translation1 = 'X'">
												<xsl:text>no</xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>yes</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</logo>
									<category>
										<xsl:variable name="TVSHOPNAME">
											<xsl:call-template name="getTVShopName"/>
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="tx_txtype/ESP_TRANSMISSIONTYPE/@name = $TVSHOPNAME">
												<xsl:text>TVSHOP</xsl:text>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates select="tx_product/ES_PRODUCT" mode="category"/>
											</xsl:otherwise>
										</xsl:choose>
									</category>
								</productinformation>
							</xsl:if>
						</xsl:if>
						<txblocks>
							<xsl:for-each select="tx_txblocks/ES_TXBLOCK/txb_timeallocationsinbreakmodel/ES_BMTIMEALLOCATION">
								<txblock>
									<xsl:variable name="btoid">
										<xsl:value-of select="@oid"/>
									</xsl:variable>
									<xsl:variable name="btype">
										<!--Time allocation type defined in WON-->
										<xsl:value-of select="type/ESP_BMTIMEALLOCATIONTYPE/@name"/>
									</xsl:variable>
									
									
									
									<xsl:variable name="btypePP">
										<!--Time allocation type defined in look-up table (for Pixel Power)-->
										<xsl:choose>
											<xsl:when test="type/ESP_BMTIMEALLOCATIONTYPE/popupLookups/POPUPLOOKUP
												[@interface = 'Pixel power'][@attribute = 'Time allocation type (BlockType)']/@translation1 != ''">
												<xsl:value-of select="type/ESP_BMTIMEALLOCATIONTYPE/popupLookups/POPUPLOOKUP
													[@interface = 'Pixel power'][@attribute = 'Time allocation type (BlockType)']/@translation1"/>
											</xsl:when>
											<xsl:otherwise><xsl:text>OTHER</xsl:text></xsl:otherwise>
										</xsl:choose>
										
									</xsl:variable>
									<xsl:variable name="isCommercial"
										select="string-length(type/ESP_BMTIMEALLOCATIONTYPE/popupLookups/POPUPLOOKUP
										[@interface = 'Pixel power'][@attribute = 'IsCommercial']/@translation1)"/>
									<!--If look-up table returns any value, this variable will be true-->
									<xsl:variable name="commercialTypePP"
										select="type/ESP_BMTIMEALLOCATIONTYPE/popupLookups/POPUPLOOKUP
										[@interface = 'Pixel power'][@attribute = 'Commercial type']/@translation1"/>
									<block-oid>
										<xsl:value-of select="$btoid"/>
									</block-oid>
									<blocktype>
										<xsl:value-of select="$btypePP"/>
										
										
									</blocktype>
									<xsl:variable name="btseqno">
										<xsl:for-each select="../ES_BMTIMEALLOCATION[type/ESP_BMTIMEALLOCATIONTYPE/@name = $btype]">
											<xsl:if test="@oid = $btoid">
												<xsl:value-of select="position()"/>
											</xsl:if>
										</xsl:for-each>
									</xsl:variable>
									<sequencenumber>
										<xsl:value-of select="$btseqno"/>
									</sequencenumber>
									<xsl:variable name="bttypetot">
										<xsl:value-of select="count(../ES_BMTIMEALLOCATION/type/ESP_BMTIMEALLOCATIONTYPE[@name = $btype])"/>
									</xsl:variable>
									<blocksofthistype>
										<xsl:value-of select="$bttypetot"/>
									</blocksofthistype>
									<txevents>	
										<xsl:for-each select="txEvents/ES_BMTXEVENT">
											<!-- Tx Start and End -->
											<xsl:variable name="txEventStartTimeInFrames" 
												select="starttimecode/ESP_SMPTETIMECODE/metricTime/ESP_TIMEDURATION/@durationinmilliseconds div 40"/>
											<xsl:variable name="txEventEndTimeInFrames" 
												select="endtimecode/ESP_SMPTETIMECODE/metricTime/ESP_TIMEDURATION/@durationinmilliseconds div 40"/>
											<!-- Credit Squeeze Start and End -->
											<xsl:variable name="creditSqueezeMarker" 
												select="txEventMediaAsset/ES_MM2MEDIAASSET/markers/ES_MM2MARKER[markerType/ESP_MARKERTYPE/@name = 'End credit'][1]"/>
											<xsl:variable name="creditSqueezeStartTimeInFrames" 
												select="$creditSqueezeMarker/timeCode/ESP_SMPTETIMECODE/metricTime/ESP_TIMEDURATION/@durationinmilliseconds div 40"/>
											<xsl:variable name="creditSqueezeEndTimeInFrames" 
												select="$creditSqueezeMarker/endTimeCode/ESP_SMPTETIMECODE/metricTime/ESP_TIMEDURATION/@durationinmilliseconds div 40"/>
											<!-- Credit Squeeze Duration with Limits -->
											<xsl:variable name="minCreditSqueezeDurationInFrames" 
												select="//tx_channel/ESP_CHANNEL/popupLookups/POPUPLOOKUP[@attribute = 'CreditSqueezeMinDur']/@translation1"/>
											<xsl:variable name="creditSqueezeDurationInFrames" 
												select="$creditSqueezeEndTimeInFrames - $creditSqueezeStartTimeInFrames"/>
											<xsl:variable name="maxCreditSqueezeDurationInFrames" 
												select="//tx_channel/ESP_CHANNEL/popupLookups/POPUPLOOKUP[@attribute = 'CreditSqueezeMaxDur']/@translation1"/>
											<!-- Squeeze time after Tx Start -->
											<xsl:variable name="creditSqueezeStartRelativeToEvent" 
												select="$creditSqueezeStartTimeInFrames - $txEventStartTimeInFrames"/>
											<!-- Min Allowed End Offset -->
											<xsl:variable name="creditSqueezeOffsetInFrames" 
												select="//tx_channel/ESP_CHANNEL/popupLookups/POPUPLOOKUP[@attribute = 'CreditSqueezeEndOffset']/@translation1"/>
											<!-- Corrected Squeeze End and Duration :: Use when Squeeze lasts too long -->
											<xsl:variable name="correctedSqueezeEndInFrames" 
												select="$txEventEndTimeInFrames - $creditSqueezeOffsetInFrames"/>
											<xsl:variable name="correctedSqueezeDurationInFrames" 
												select="$correctedSqueezeEndInFrames - $creditSqueezeStartTimeInFrames"/>
											<!-- Conditional to populate credit squeeze elements -->
											<xsl:variable name="isCreditSqueezeEvent" 
												select="timeAllocationType/ESP_BMTIMEALLOCATIONTYPE/@predefined = 'programSegment' 
												and $creditSqueezeStartTimeInFrames &gt;= $txEventStartTimeInFrames
												and $creditSqueezeStartTimeInFrames &lt;= ($txEventEndTimeInFrames - $creditSqueezeOffsetInFrames - $minCreditSqueezeDurationInFrames)
												and $creditSqueezeDurationInFrames &gt; $minCreditSqueezeDurationInFrames
												and $creditSqueezeDurationInFrames &lt; $maxCreditSqueezeDurationInFrames"/>
											<!-- Secondary Event TxEvent Start Time -->
											<xsl:variable name="txEventStartTimeInFrames2" 
												select="starttime/ESP_SMPTETIME/metricTime/ESP_TIMEDURATION/@durationinmilliseconds div 40"/>
											<txevent>
												<xsl:variable name="txoid">
													<xsl:value-of select="@oid"/>
												</xsl:variable>
												<txevent-title>
													<xsl:value-of select="@title"/>
												</txevent-title>
												<txevent-oid>
													<xsl:value-of select="$txoid"/>
												</txevent-oid>
												<txeventtype>
													<xsl:choose>
														<xsl:when test="txortxeventproduct/ES_PRODUCT/p_product_category/ESP_PRODUCTCATEGORY/@name = 'Homeshopping'">
															<xsl:text>HOMESHOPPING</xsl:text>
														</xsl:when>
														
														<!--If it's a commercial (as defined in the look-up table 'isCommercial'),
															we take the translation from the look-up table 'Commercial type'-->
														<xsl:when test="$isCommercial">
															<xsl:value-of select="$commercialTypePP"/>
														</xsl:when>
														<!--If not a commercial, we take the value as defined in the look-up table 'time allocation type'-->
														<xsl:when test="$btypePP">
															<xsl:value-of select="$btypePP"/>
														</xsl:when>
														<!--Otherwise, simply the time allocation type name in WON-->
														<xsl:otherwise>
															<xsl:value-of select="$btype"/>
														</xsl:otherwise>
													</xsl:choose>
												</txeventtype>
												<mediaid>
													<xsl:choose>
														<xsl:when test="string-length(@medialabel) &gt; 0">
															<xsl:value-of select="normalize-space(@medialabel)"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>0</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</mediaid>
												<reconcilekey>
													<xsl:value-of select="@reconcilekey"/>
												</reconcilekey>
												<actualstarttime>
													<xsl:apply-templates select="starttime/ESP_SMPTETIME/metricTime/ESP_TIMEDURATION"/>
												</actualstarttime>
												<actualdate>
													<xsl:value-of select="concat(calendardate/ESP_DATE/@date, 'T00:00:00.000')"/>
												</actualdate>
												<actualduration>
													<xsl:apply-templates select="duration/ESP_SMPTEDURATION/metricDuration/ESP_TIMEDURATION"/>
												</actualduration>
												<aspectratio>
													<xsl:choose>
														<xsl:when test="string-length(imageformat/ESP_IMAGEFORMAT/@name) &gt; 0">
															<xsl:value-of select="imageformat/ESP_IMAGEFORMAT/@name"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>16:9</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</aspectratio>
												<videoformat>
													<xsl:choose>
														<xsl:when test="string-length(videoFormat/ESP_VMVIDEOFORMAT/@name) &gt; 0">
															<xsl:value-of select="videoFormat/ESP_VMVIDEOFORMAT/@name"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>SD</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</videoformat>
												<artistname>
													<xsl:choose>
														<xsl:when test="string-length(txortxeventproduct/ES_PRODUCT/@mc_externalartist) &gt; 0">
															<xsl:value-of select="txortxeventproduct/ES_PRODUCT/@mc_externalartist"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>None</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</artistname>
												<songtitle>
													<xsl:choose>
														<xsl:when test="string-length(txortxeventproduct/ES_PRODUCT/@mc_externaltitle) &gt; 0">
															<xsl:value-of select="txortxeventproduct/ES_PRODUCT/@mc_externaltitle"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>None</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</songtitle>
												
												<creditsqueezestart>
													<xsl:choose>
														<xsl:when test="$isCreditSqueezeEvent">
															<xsl:call-template name="buildtimecode">
																<xsl:with-param name="rem-frames" select="$creditSqueezeStartRelativeToEvent"/>
																<xsl:with-param name="offset-id" select="'+'"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>no</xsl:otherwise>
													</xsl:choose>
												</creditsqueezestart>
												<creditsqueezeDur>
													<xsl:choose>
														<xsl:when test="$isCreditSqueezeEvent">
															<xsl:choose>
																<!-- end of credit squeeze falls within limits  -->
																<xsl:when test="$creditSqueezeEndTimeInFrames &lt;= $correctedSqueezeEndInFrames">
																	<xsl:call-template name="buildtimecode">
																		<xsl:with-param name="rem-frames" select="$creditSqueezeDurationInFrames"/>
																		<xsl:with-param name="offset-id" select="''"/>
																	</xsl:call-template>
																</xsl:when>
																<xsl:otherwise>
																	<!-- Offset is too small, therefore we will trim the duration  -->																	
																	<xsl:call-template name="buildtimecode">
																		<xsl:with-param name="rem-frames" select="$correctedSqueezeDurationInFrames"/>
																		<xsl:with-param name="offset-id" select="''"/>
																	</xsl:call-template>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:otherwise>no</xsl:otherwise>
													</xsl:choose>
												</creditsqueezeDur>
												<xsl:if test="secondaryevents/ES_SECONDARYEVENT">
													<secondaryevents>
														<xsl:for-each select="secondaryevents/ES_SECONDARYEVENT">
															<secondaryevent>
																<rulecode>
																	<xsl:value-of select="@se_identification"/>
																	<xsl:call-template name="se_text">
																		<xsl:with-param name="list" select="graphicItems/ES_GRAPHICITEM"/>
																	</xsl:call-template>
																</rulecode>
																<ID2>
																	<xsl:choose>
																		<xsl:when test="@identification2">
																			<xsl:value-of select="@identification2"/>
																		</xsl:when>
																	</xsl:choose>
																</ID2>
																<Carrier>
																	<xsl:choose>
																		<xsl:when test="se_timeallocation/ES_BMTIMEALLOCATION/txEvents/ES_BMTXEVENT/
																			txEventVideoComponent/ES_MM2VIDEOCOMPONENT/mediaAsset/ES_MM2MEDIAASSET/@label">
																			<xsl:value-of select="se_timeallocation/ES_BMTIMEALLOCATION/txEvents/ES_BMTXEVENT/
																				txEventVideoComponent/ES_MM2VIDEOCOMPONENT/mediaAsset/ES_MM2MEDIAASSET/@label"/>
																		</xsl:when>
																	</xsl:choose>
																</Carrier>
																<timecode>
																	<xsl:variable name="timecodevar">
																		<xsl:variable name="secondaryEventStartInFrames"
																			select="startTime/ESP_SMPTETIME/metricTime/ESP_TIMEDURATION/@durationinmilliseconds div 40"/>
																		<xsl:variable name="remaining-frames" select="$secondaryEventStartInFrames - $txEventStartTimeInFrames2"/>
																		<xsl:call-template name="buildtimecode">
																			<xsl:with-param name="rem-frames" select="$remaining-frames"/>
																			<xsl:with-param name="offset-id" select="''"/>
																		</xsl:call-template>
																	</xsl:variable>
																	<xsl:value-of select="concat('+', $timecodevar)"/>
																</timecode>
																<reconcilekey>
																	<xsl:value-of select="@oid"/>
																</reconcilekey>
															</secondaryevent>
														</xsl:for-each>
													</secondaryevents>
												</xsl:if>
											</txevent>
										</xsl:for-each>
									</txevents>
								</txblock>
							</xsl:for-each>
						</txblocks>
					</transmission>
				</xsl:for-each>
			</transmissions>
		</transmissionschedule>
	</xsl:template>

	<xsl:template name="buildtimecode">
		<xsl:param name="rem-frames"/>
		<xsl:param name="offset-id"/>

		<xsl:variable name="new-hours" select="floor($rem-frames div (60 * 60 * 25))"/>
		<xsl:variable name="remaining-framesM" select="$rem-frames mod (60 * 60 * 25)"/>
		<xsl:variable name="new-minutes" select="floor($remaining-framesM div (60 * 25))"/>
		<xsl:variable name="remaining-framesS" select="$rem-frames mod (60 * 25)"/>
		<xsl:variable name="new-seconds" select="floor($remaining-framesS div 25)"/>
		<xsl:variable name="new-frames" select="$remaining-framesS mod 25"/>

		<xsl:value-of select="$offset-id"/>
		<xsl:value-of select="format-number($new-hours, '00')"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="format-number($new-minutes, '00')"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="format-number($new-seconds, '00')"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="format-number($new-frames, '00')"/>
	</xsl:template>

	<xsl:template match="ESP_TIMEINSTANT" mode="datetime">
		<xsl:value-of select="concat(@date, 'T', @time)"/>
	</xsl:template>


	<xsl:template match="ESP_TIMEINSTANT" mode="displaytime">
		<xsl:value-of select="concat(format-number(@hours, '00'), '.', format-number(@minutes, '00'))"/>
	</xsl:template>

	<xsl:template name="truefalse2yesno">
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="$value = 'true'">
				<xsl:text>yes</xsl:text>
			</xsl:when>
			<xsl:when test="$value = 'false'">
				<xsl:text>no</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ESP_TIMEDURATION">
		<xsl:value-of
			select="concat(format-number(@hours, '00'), ':', format-number(@minutes, '00'), ':',
			format-number(@seconds, '00'), ':', format-number(@milliseconds div 40, '00'))"/>
	</xsl:template>

	<xsl:template name="getTVShopName">
		<xsl:text>Tele Shopping</xsl:text>
	</xsl:template>
	
	<xsl:template name="getTitle">
		<xsl:param name="channelTerritoryCode"/>
		<xsl:param name="titles"/>
			<xsl:variable name="firstTitle"
				select="$titles/ES_PRODUCTTITLE[pt_type/ESP_PRODUCTTITLETYPE/popupLookups/POPUPLOOKUP
				[@interface = 'Pixel power'][@attribute = 'Title type']/@translation1 = $channelTerritoryCode]/@pt_title"/>
			<xsl:variable name="secondTitle"
				select="$titles/ES_PRODUCTTITLE[pt_type/ESP_PRODUCTTITLETYPE/popupLookups/POPUPLOOKUP
				[@interface = 'Pixel power'][@attribute = 'Title type']/@translation2 = $channelTerritoryCode]/@pt_title"/>
			<xsl:variable name="originalTitle"
				select="$titles/ES_PRODUCTTITLE[pt_type/ESP_PRODUCTTITLETYPE/popupLookups/POPUPLOOKUP
				[@interface = 'Pixel power'][@attribute = 'Title type']/@translation3 = $channelTerritoryCode]/@pt_title"/>
			<xsl:choose>
				<xsl:when test="$firstTitle">
					<xsl:value-of select="$firstTitle"/>
				</xsl:when>
				<xsl:when test="$secondTitle">
					<xsl:value-of select="$secondTitle"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$originalTitle"/>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<xsl:template match="ES_PRODUCT" mode="category">
		<xsl:choose>
			<xsl:when test="p_product_category/ESP_PRODUCTCATEGORY/@name = 'Gameshow'">
				<xsl:text>TVSHOP</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>OTHER</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="se_text">
		<!-- Recursive template that will always print 9 delimiters, regardless of actual amount of graphic items  -->
		<xsl:param name="list"/>
		<xsl:param name="current" select="1"/>
		<xsl:param name="max" select="10"/>
		<xsl:value-of select="concat('|', $list[graphicType/ESP_SECONDARYEVENTGRAPHICTYPE/@name = concat('text', $current)]/@graphicText)"/>
		<xsl:if test="$current &lt; $max">
			<xsl:call-template name="se_text">
				<xsl:with-param name="list" select="$list"/>
				<xsl:with-param name="current" select="$current + 1"/>
				<xsl:with-param name="max" select="$max"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
