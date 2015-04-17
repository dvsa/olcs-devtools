<?php

namespace Devtools;

use PHPMD\AbstractRenderer;
use PHPMD\Report;

/**
 * Custom Text Renderer
 *
 * @author Rob Caiger <rob@clocal.co.uk>
 */
class CustomTextRenderer extends AbstractRenderer
{
    /**
     * This method will be called when the engine has finished the source analysis
     * phase.
     *
     * @param \PHPMD\Report $report
     * @return void
     */
    public function renderReport(Report $report)
    {
        $writer = $this->getWriter();
        $writer->write(PHP_EOL);

        $problems = [];

        foreach ($report->getRuleViolations() as $violation) {

            $fileName = $violation->getFileName();

            if (strpos($fileName, getcwd()) === 0) {
                $fileName = '.' . substr($fileName, strlen(getcwd()));
            }

            if (!isset($problems[$fileName])) {
                $problems[$fileName] = [
                    'violations' => [],
                    'errors' => [],
                    'settings' => [
                        'maxLineNoLength' => 0
                    ]
                ];
            }

            $problems[$fileName]['violations'][] = $violation;
            $problems[$fileName]['settings']['maxLineNoLength'] = max(
                [
                    $problems[$fileName]['settings']['maxLineNoLength'],
                    strlen($violation->getBeginLine())
                ]
            );
        }

        foreach ($report->getErrors() as $error) {

            $fileName = $error->getFile();

            if (strpos($fileName, getcwd()) === 0) {
                $fileName = '.' . substr($fileName, strlen(getcwd()));
            }

            if (!isset($problems[$fileName])) {
                $problems[$fileName] = [
                    'violations' => [],
                    'errors' => []
                ];
            }

            $problems[$fileName]['errors'][] = $error;
        }

        $writer->write(PHP_EOL);
        $writer->write(str_repeat('#', 100));
        $writer->write(PHP_EOL);

        foreach ($problems as $fileName => $fileProblems) {
            $writer->write($fileName);
            $writer->write(PHP_EOL);
            $writer->write(PHP_EOL);
            $writer->write(count($fileProblems['violations']) . ' Violations');
            $writer->write(PHP_EOL);
            $writer->write(PHP_EOL);

            foreach ($fileProblems['violations'] as $violation) {

                $line = str_pad(
                    $violation->getBeginLine(),
                    $fileProblems['settings']['maxLineNoLength'],
                    ' ',
                    STR_PAD_LEFT
                );

                $writer->write($line);
                $writer->write(' | ');
                $writer->write($violation->getDescription());
                $writer->write(PHP_EOL);
            }

            $writer->write(PHP_EOL);
            $writer->write(count($fileProblems['errors']) . ' Errors');
            $writer->write(PHP_EOL);
            $writer->write(PHP_EOL);

            foreach ($fileProblems['errors'] as $error) {
                $writer->write('ERROR | ');
                $writer->write($error->getMessage());
                $writer->write(PHP_EOL);
            }
            $writer->write(PHP_EOL);
            $writer->write(str_repeat('#', 100));
            $writer->write(PHP_EOL);
        }
    }
}
